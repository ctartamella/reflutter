import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart' as meta;
import 'package:source_gen/source_gen.dart';
import 'package:reflutter/reflutter.dart';
import 'utils.dart';

final Logger _log = new Logger('ReflutterHttpGenerator');

/// The main geneator class used by build_runner.
class ReflutterHttpGenerator extends GeneratorForAnnotation<ReflutterHttp> {
  final _methodsAnnotations = const [Get, Post, Delete, Put, Patch];

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final friendlyName = element.name;
    if (element is! ClassElement) {
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the JaguarHttp annotation from `$friendlyName`.');
    }

    final ClassElement classElement = element;
    _log.info('Processing class ${classElement.name}.');

    final clazz = new Class((b) {
      b
        ..name = annotation?.peek('name')?.stringValue ?? '${friendlyName}Impl'
        ..extend = refer('$ReflutterApiDefinition')
        ..implements.add(refer(friendlyName))
        ..constructors.add(_generateConstructor());

      _log.info('Processing ${classElement.methods.length} methods.');

      for (var m in classElement.methods) {
        if (m != null) b.methods.add(_generateMethod(m));
      }

      _log.info('${b.name}: Found ${b.methods.build().length} methods.');
    });

    return new DartFormatter().format('${clazz.accept(new DartEmitter())}');
  }

  Method _generateMethod(MethodElement m) {
    final methodAnnot = _getMethodAnnotation(m);
    if (methodAnnot == null ||
        !m.isAbstract ||
        !m.returnType.isDartAsyncFuture) {
      _log.warning('Skipping method ${m.name}');
      return null;
    }

    _log.info('Adding method ${m.name}.');

    final override = new Block.of([const Code('override')]);
    return new Method((b) {
      b
        ..name = m.name
        ..returns = _genericTypeBuilder(m.returnType)
        ..modifier = MethodModifier.async
        ..body = _generateMethodBlock(m, methodAnnot)
        ..annotations.addAll([new CodeExpression(override)]);

      for (var param in m.parameters) {
        b.requiredParameters.add(new Parameter((b) => b
          ..name = param.name
          ..type = new TypeReference((b) => b.symbol = '${param.type.name}')));
      }
    });
  }

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);

  DartType _genericOf(DartType type) =>
      type is InterfaceType && type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  TypeReference _genericTypeBuilder(DartType type) {
    final generic = _genericOf(type);
    if (generic == null) {
      return new TypeReference((b) => b.symbol = type.name);
    }
    return new TypeReference((b) => b
      ..symbol = type.name
      ..types.addAll([_genericTypeBuilder(generic)]));
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

  Constructor _generateConstructor() => new Constructor((b) => b
    ..requiredParameters.addAll([
      new Parameter((b) => b
        ..name = kClient
        ..type = kHttpClientType)
    ])
    ..requiredParameters.addAll([
      new Parameter((b) => b
        ..name = kBaseUrl
        ..type = kStringType)
    ])
    ..requiredParameters.addAll([
      new Parameter((b) => b
        ..name = kHeaders
        ..type = kMapType)
    ])
    ..initializers.add(const Code('super(client, baseUrl, headers)')));

  Block _generateMethodBlock(MethodElement m, ConstantReader methodAnnot) =>
      new Block((b) => b
        ..addExpression(_generateUrl(m, methodAnnot))
        ..addExpression(_generateRequest(m, methodAnnot))
        ..addExpression(_generateInterceptRequest())
        ..addExpression(_generateSendRequest())
        ..addExpression(_generateVarResponse())
        ..addExpression(_generateResponseProcess(m))
        ..addExpression(_generateInterceptResponseReturn()));

  Expression _generateUrl(MethodElement method, ConstantReader annot) {
    var value = '${annot
        .read('url')
        .stringValue}';
    final query = <String, String>{};
    for (var p in method.parameters) {
      if (p.isPositional) {
        final pAnnot = _getParamAnnotation(p);
        if (pAnnot != null) {
          final key = ':${pAnnot
              ?.peek('name')
              ?.stringValue ?? p.name}';
          value = value.replaceFirst(key, '\$${p.name}');
        }
      } else if (p.isNamed) {
        final pAnnot = _getQueryParamAnnotation(p);
        if (pAnnot != null) {
          query[pAnnot?.peek('name')?.stringValue ?? p.name] = p.name;
        }
      }
    }

    if (query.isNotEmpty) {
      var q = '{';
      query.forEach((key, val) {
        q += "$key': '\$$val',";
      });
      q += '}';

      return literal('\$$kBaseUrl$value?\${$kParamsToQueryUri($q)}')
          .assignFinal(kUrl);
    }

    return literal('\$$kBaseUrl$value').assignFinal(kUrl);
  }

  Expression _generateVarResponse() => literalNull.assignVar(kResponse);

  Expression _generateRequest(MethodElement method, ConstantReader annot) {
    final params = {
      kMethod: new Code("'${annot
          .peek('method')
          .stringValue}'"),
      kUrl: kUrlRef,
      kHeaders: kHeadersRef
    };

    for (var p in method.parameters) {
      final pAnnot = _getBodyAnnotation(p);
      if (pAnnot != null) {
        params[kBody] = kJsonRef.property("encode").call([refer(p.name)]);
      }
    }

    return kReflutterRequestRef.newInstance([], params).assignVar(kRequest);
  }

  Expression _generateInterceptRequest() =>
      kRequestRef.assign(kInterceptReqRef.call([kRequestRef]).awaited);

  Expression _generateInterceptResponseReturn() =>
      kInterceptResRef.call([kResponseRef]).awaited.returned;

  Reference _generateSendRequest() => kRequestRef
      .property(kSendMethod)
      .call([kClientRef])
      .awaited
      .assignFinal(kRawResponse);

  Expression _generateResponseProcess(MethodElement method) {
    final responseType = getResponseType(method.returnType);
    final respTypeName = responseType?.displayName;
    final type = this._genericOf(responseType)?.displayName;

    print(respTypeName);
    print(type);
    if (!respTypeName.startsWith("ReflutterResponse")) {
      throw new Exception(
          "Method return types should be of type ReflutterResponse. Instead, got $respTypeName<$type>");
    }

    var responseCode =
        'new ReflutterResponse(new $type.fromJson(json.decode(rawResponse.body)), rawResponse)';
    if (type == "dynamic") {
      responseCode = 'new ReflutterResponse.empty(rawResponse)';
    }

    // if (type.startsWith("List")) {
    //   responseCode = new List<String>.from();
    // }

    final block = new Block.of([
      const Code('if (responseSuccessful(rawResponse)) {'),
      new Code('  response = $responseCode;'),
      const Code('} else {'),
      const Code(
          '  response = new ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);'),
      const Code('}')
    ]);

    return new CodeExpression(block);
  }

  @meta.visibleForTesting
  DartType getResponseType(DartType type) {
    final generic = _genericOf(type);
    if (generic == null) {
      return type;
    }
    if (generic.isDynamic) {
      return null;
    }
    return generic;
  }
}
