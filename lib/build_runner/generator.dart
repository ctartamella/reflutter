import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart' as builder;
import '../reflutter.dart';
import "utils.dart";

final Logger _log = new Logger("ReflutterHttpGenerator");

class ReflutterHttpGenerator extends GeneratorForAnnotation<ReflutterHttp> {

  final _methodsAnnotations = const [Get, Post, Delete, Put, Patch];

  const ReflutterHttpGenerator(); 

  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    var friendlyName = element.name;
    if (element is! ClassElement) {
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the JaguarHttp annotation from `$friendlyName`.');
    }

    var classElement = element as ClassElement;
    _log.info('Processing class ${classElement.name}.');

    var clazz = new builder.Class((b) {
      b..name = annotation?.peek("name")?.stringValue ?? "${friendlyName}Impl"
       ..extend = builder.refer("$ReflutterApiDefinition")
       ..implements.add(builder.refer(friendlyName))
       ..constructors.add(_generateConstructor());      

      _log.info('Processing ${classElement.methods.length} methods.');

      classElement.methods.forEach((m) {
        if (m != null)
          b.methods.add(_generateMethod(m));
      });

      _log.info('${b.name}: Found ${b.methods.build().length} methods.');      
    });
    
    final emitter = new DartEmitter(new Allocator.simplePrefixing());
    return new DartFormatter().format('${clazz.accept(new DartEmitter())}');
  }

  builder.Method _generateMethod(MethodElement m) {
    final methodAnnot = _getMethodAnnotation(m); 
    if (methodAnnot == null || !m.isAbstract || !m.returnType.isDartAsyncFuture) {
        _log.warning('Skipping method ${m.name}');
        return null;
    }
    
    _log.info('Adding method ${m.name}.');

    return new builder.Method((b) {
      b..name = m.name
        ..returns = _genericTypeBuilder(m.returnType)
        ..modifier = builder.MethodModifier.async
        ..body = _generateMethodBlock(m, methodAnnot);
      
      m.parameters.forEach((ParameterElement param) {         
        b.requiredParameters.add(new builder.Parameter((b) => b
          ..name = param.name
          ..type = new builder.TypeReference((b) => b.symbol = "${param.type.name}"))
        );
      });          
    });
  }

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);

  DartType _genericOf(DartType type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty
        ? type.typeArguments.first
        : null;
  }

  TypeReference _genericTypeBuilder(DartType type) {
    final generic = _genericOf(type);
    if (generic == null) {
      return new TypeReference((b) => b.symbol = type.name );
    }
    return new TypeReference((b) => b
      ..symbol = type.name
      ..types.addAll([ _genericTypeBuilder(generic)])
    );
}

  ConstantReader _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annot != null) return new ConstantReader(annot);
    }
    return null;
  }

  ConstantReader _getParamAnnotation(ParameterElement param) =>
      new ConstantReader(_typeChecker(Param)
          .firstAnnotationOf(param, throwOnUnresolved: false));

  ConstantReader _getQueryParamAnnotation(ParameterElement param) =>
      new ConstantReader(_typeChecker(QueryParam)
          .firstAnnotationOf(param, throwOnUnresolved: false));

  ConstantReader _getBodyAnnotation(ParameterElement param) =>
      new ConstantReader(_typeChecker(Body)
          .firstAnnotationOf(param, throwOnUnresolved: false));

  
  builder.Constructor _generateConstructor() => new builder.Constructor((b) => b
    ..requiredParameters.addAll([new builder.Parameter((b) => b..name = kClient..type = kHttpClientType)])
    ..requiredParameters.addAll([new builder.Parameter((b) => b..name = kBaseUrl..type = kStringType)])
    ..requiredParameters.addAll([new builder.Parameter((b) => b..name = kHeaders..type = kMapType)])
    ..requiredParameters.addAll([new builder.Parameter((b) => b..name = kSerializers..type = kSerializerType)])
    ..initializers.add(const builder.Code('super(client, baseUrl, headers, serializers)')));

  builder.Block _generateMethodBlock(MethodElement m, ConstantReader methodAnnot) => new builder.Block((b) => b
      ..addExpression(_generateUrl(m, methodAnnot))
      ..addExpression(_generateRequest(m, methodAnnot))
      ..addExpression(_generateInterceptRequest())
      ..addExpression(_generateSendRequest())
      ..addExpression(_generateVarResponse())
      ..addExpression(_generateResponseProcess(m))
      ..addExpression(_generateInterceptResponse())
      ..addExpression(kResponseRef.returned)
    );

  builder.Expression _generateUrl(MethodElement method, ConstantReader annot) {
    String value = "${annot
        .read("url")
        .stringValue}";
    Map query = <String, String>{};
    method.parameters?.forEach((ParameterElement p) {
      if (p.isPositional) {
        final pAnnot = _getParamAnnotation(p);
        if (pAnnot != null) {
          String key = ":${pAnnot
              ?.peek("name")
              ?.stringValue ?? p.name}";
          value = value.replaceFirst(key, "\${${p.name}}");
        }
      } else if (p.isNamed) {
        final pAnnot = _getQueryParamAnnotation(p);
        if (pAnnot != null) {
          query[pAnnot?.peek("name")?.stringValue ?? p.name] = p.name;
        }
      }
    });

    if (query.isNotEmpty) {
      String q = "{";
      query.forEach((key, val) {
        q += '"$key": "\$$val",';
      });
      q += "}";

      return builder.literal('\$$kBaseUrl$value?\${$kParamsToQueryUri($q)}')
        .assignFinal(kUrl);
    }

    return builder.literal('\$$kBaseUrl$value').assignFinal(kUrl);
  }

  builder.Expression _generateVarResponse() => builder.literalNull.assignVar(kResponse);

  builder.Expression _generateRequest(MethodElement method, ConstantReader annot) {
    final params = {      
      kMethod: new builder.Code("'${annot
          .peek("method")
          .stringValue}'"),
      kUrl: kUrlRef,
      kHeaders: kHeadersRef
    };

    method.parameters?.forEach((ParameterElement p) {
      final pAnnot = _getBodyAnnotation(p);
      if (pAnnot != null) {
        params[kBody] =
            kSerializersRef.property(kSerializeMethod).call([builder.refer(p.name)]);
      }
    });

    return kReflutterRequestRef.newInstance([], params).assignVar(kRequest);
  }

  builder.Expression _generateInterceptRequest() =>
    kRequestRef.assign(kInterceptReqRef.call([kRequestRef]).awaited);

  builder.Expression _generateInterceptResponse() =>
    kResponseRef.assign(kInterceptResRef.call([kResponseRef]).awaited);

  builder.Reference _generateSendRequest() => 
    kRequestRef.property(kSendMethod).call([kClientRef]).awaited.assignFinal(kRawResponse);

  builder.Expression _generateResponseProcess(MethodElement method) {
    var block = new builder.Block.of([
      const builder.Code('if (responseSuccessful(rawResponse)) {'),
      const builder.Code('  response = new ReflutterResponse('),
      const builder.Code('      serializers.deserialize(rawResponse.body, type: User), rawResponse);'),
      const builder.Code('} else {'),
      const builder.Code('  response = new ReflutterResponse.error(rawResponse);'),
      const builder.Code('}')
    ]);

    return new builder.CodeExpression(block);
  }
}