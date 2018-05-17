import 'dart:async';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen/src/utils.dart';
import 'package:code_builder/code_builder.dart';
import 'package:logging/logging.dart';
import '../../flutter_refit.dart';
import "utils.dart";

final _log = new Logger("JaguarHttpGenerator");

class JaguarHttpGenerator extends GeneratorForAnnotation<RefitHttp> {
  const JaguarHttpGenerator();

  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      var friendlyName = friendlyNameForElement(element);
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the JaguarHttp annotation from `$friendlyName`.');
    }

    return _buildImplementionClass(annotation, element);
  }

  String _buildImplementionClass(
      ConstantReader annotation, ClassElement element) {
    var friendlyName = element.name;

    ReferenceBuilder base = reference(friendlyName);
    ReferenceBuilder core = reference("$RefitApiDefinition");
    ClassBuilder clazz = new ClassBuilder(
        annotation?.peek("name")?.stringValue ?? "${friendlyName}Impl",
        asWith: [base],
        asExtends: core);

    _buildConstructor(clazz);

    element.methods.forEach((MethodElement m) {
      final methodAnnot = _getMethodAnnotation(m);
      if (methodAnnot != null &&
          m.isAbstract &&
          m.returnType.isDartAsyncFuture) {
        TypeBuilder returnType = _genericTypeBuilder(m.returnType);

        MethodBuilder methodBuilder = new MethodBuilder(m.name,
            returnType: returnType, modifier: MethodModifier.asAsync);

        final statements = [
          _generateUrl(m, methodAnnot),
          _generateRequest(m, methodAnnot),
          _generateInterceptRequest(),
          _generateSendRequest(),
          varField(kResponse),
          _generateResponseProcess(m),
          _generateInterceptResponse(),
          kResponseRef.asReturn()
        ];

        methodBuilder.addStatements(statements);

        m.parameters.forEach((ParameterElement param) {
          if (param.parameterKind == ParameterKind.NAMED) {
            methodBuilder.addNamed(new ParameterBuilder(param.name,
                type: new TypeBuilder(param.type.name)));
          } else {
            methodBuilder.addPositional(new ParameterBuilder(param.name,
                type: new TypeBuilder(param.type.name)));
          }
        });

        clazz.addMethod(methodBuilder);
      }
    });

    return clazz.buildClass().toString();
  }

  _buildConstructor(ClassBuilder clazz) {
    clazz.addConstructor(new ConstructorBuilder(
        invokeSuper: [kClientRef, kBaseUrlRef, kHeadersRef, kSerializersRef])
      ..addNamed(new ParameterBuilder(kClient, type: kHttpClientType))
      ..addNamed(new ParameterBuilder(kBaseUrl, type: kStringType))
      ..addNamed(new ParameterBuilder(kHeaders, type: kMapType))
      ..addNamed(new ParameterBuilder(kSerializers, type: kSerializerType)));
  }

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);

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

  final _methodsAnnotations = const [Get, Post, Delete, Put, Patch];

  DartType _genericOf(DartType type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty
        ? type.typeArguments.first
        : null;
  }

  TypeBuilder _genericTypeBuilder(DartType type) {
    final generic = _genericOf(type);
    if (generic == null) {
      return new TypeBuilder(type.name);
    }
    return new TypeBuilder(type.name, genericTypes: [
      _genericTypeBuilder(generic),
    ]);
  }

  DartType _getResponseType(DartType type) {
    final generic = _genericOf(type);
    if (generic == null) {
      return type;
    }
    if (generic.isDynamic) {
      return null;
    }
    return _getResponseType(generic);
  }

  StatementBuilder _generateUrl(MethodElement method, ConstantReader annot) {
    String value = "${annot
        .read("url")
        .stringValue}";
    Map query = <String, String>{};
    method.parameters?.forEach((ParameterElement p) {
      if (p.parameterKind == ParameterKind.POSITIONAL) {
        final pAnnot = _getParamAnnotation(p);
        if (pAnnot != null) {
          String key = ":${pAnnot
              ?.peek("name")
              ?.stringValue ?? p.name}";
          value = value.replaceFirst(key, "\${${p.name}}");
        }
      } else if (p.parameterKind == ParameterKind.NAMED) {
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

      return literal('\$$kBaseUrl$value?\${$kParamsToQueryUri($q)}')
          .asFinal(kUrl);
    }

    return literal('\$$kBaseUrl$value').asFinal(kUrl);
  }

  StatementBuilder _generateRequest(
      MethodElement method, ConstantReader annot) {
    final params = {
      kMethod: new ExpressionBuilder.raw((_) => "'${annot
          .peek("method")
          .stringValue}'"),
      kUrl: kUrlRef,
      kHeaders: kHeadersRef
    };

    method.parameters?.forEach((ParameterElement p) {
      final pAnnot = _getBodyAnnotation(p);
      if (pAnnot != null) {
        params[kBody] =
            kSerializersRef.invoke(kSerializeMethod, [reference(p.name)]);
      }
    });

    return kJaguarRequestRef.newInstance([], named: params).asVar(kRequest);
  }

  StatementBuilder _generateInterceptRequest() =>
      kInterceptReqRef.call([kRequestRef]).asAwait().asAssign(kRequestRef);

  StatementBuilder _generateInterceptResponse() =>
      kInterceptResRef.call([kResponseRef]).asAwait().asAssign(kResponseRef);

  StatementBuilder _generateSendRequest() => varFinal(kRawResponse,
      value: kRequestRef.invoke(kSendMethod, [kClientRef]).asAwait());

  StatementBuilder _generateResponseProcess(MethodElement method) {
    final named = {};

    final responseType = _getResponseType(method.returnType);

    if (responseType != null) {
      named[kType] = new ExpressionBuilder.raw((_) => "${responseType.name}");
    }

    return ifThen(kResponseSuccessfulRef.call([kRawResponseRef]))
      ..addStatement(kJaguarResponseRef.newInstance([
        kSerializersRef.invoke(kDeserializeMethod, [kRawResponseBodyRef],
            namedArguments: named),
        kRawResponseRef
      ]).asAssign(kResponseRef))
      ..setElse(kJaguarResponseRef.newInstance([kRawResponseRef],
          constructor: kError).asAssign(kResponseRef));
  }
}