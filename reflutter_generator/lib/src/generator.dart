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

final Logger _log = Logger('ReflutterHttpGenerator');

/// The main geneator class used by build_runner.
class ReflutterHttpGenerator extends GeneratorForAnnotation<ReflutterHttp> {
  final _methodsAnnotations = const [Get, Post, Delete, Put, Patch];
  String _value = '';
  String _queryString = '';

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final friendlyName = element.name;
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.');
    }

    final ClassElement classElement = element;
    _log.info('Processing class ${classElement.name}.');

    final clazz = Class((b) {
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

    //return '${clazz.accept(new DartEmitter())}';
    return DartFormatter().format('${clazz.accept(DartEmitter())}');
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

    final override = Block.of([const Code('override')]);
    return Method((b) {
      b
        ..name = m.name
        ..returns = _genericTypeBuilder(m.returnType)
        ..modifier = MethodModifier.async
        ..body = _generateMethodBlock(m, methodAnnot)
        ..annotations.addAll([CodeExpression(override)]);

      for (var param in m.parameters) {
        var p = Parameter((b) {
          b
            ..name = param.name
            ..type = TypeReference((b) => b.symbol = '${param.type.name}')
            ..named = param.isNamed;

          if (null != param.defaultValueCode)
            b.defaultTo = Code(param.defaultValueCode);
        });

        if (param.isOptional)
          b.optionalParameters.add(p);
        else
          b.requiredParameters.add(p);
      }
    });
  }

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  DartType _genericOf(DartType type) =>
      type is InterfaceType && type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  TypeReference _genericTypeBuilder(DartType type) {
    final generic = _genericOf(type);
    if (generic == null) {
      return TypeReference((b) => b.symbol = type.name);
    }
    return TypeReference((b) => b
      ..symbol = type.name
      ..types.addAll([_genericTypeBuilder(generic)]));
  }

  ConstantReader _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annot != null) return ConstantReader(annot);
    }
    return null;
  }

  ConstantReader _getParamAnnotation(ParameterElement param) => ConstantReader(
      _typeChecker(Param).firstAnnotationOf(param, throwOnUnresolved: false));

  ConstantReader _getQueryParamAnnotation(ParameterElement param) =>
      ConstantReader(_typeChecker(QueryParam)
          .firstAnnotationOf(param, throwOnUnresolved: false));

  ConstantReader _getBodyAnnotation(ParameterElement param) => ConstantReader(
      _typeChecker(Body).firstAnnotationOf(param, throwOnUnresolved: false));

  Constructor _generateConstructor() => Constructor((b) => b
    ..requiredParameters.addAll([
      Parameter((b) => b
        ..name = kClient
        ..type = kHttpClientType),
      Parameter((b) => b
        ..name = kBaseUrl
        ..type = kStringRef)
    ])
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = kHeaders
        ..named = true
        ..type = kMapType)
    ])
    ..initializers.add(const Code('super(client, baseUrl, headers)')));

  Block _generateMethodBlock(MethodElement m, ConstantReader methodAnnot) =>
      Block((b) {
        _parseParameters(m, methodAnnot);

        if (_queryString != '') b.addExpression(_generateQuery(m, methodAnnot));

        b
          ..addExpression(_generateUrl(m, methodAnnot))
          ..addExpression(_generateRequest(m, methodAnnot))
          ..addExpression(_generateInterceptRequest())
          ..addExpression(_generateSendRequest())
          ..addExpression(_generateVarResponse())
          ..addExpression(_generateResponseProcess(m))
          ..addExpression(_generateInterceptResponseReturn(m));

        _value = '';
        _queryString = '';
      });

  void _parseParameters(MethodElement method, ConstantReader annot) {
    _value = '${annot.read('url').stringValue}';

    var query = {};
    for (var p in method.parameters) {
      if (p.isPositional) {
        final pAnnot = _getParamAnnotation(p);
        if (pAnnot != null) {
          final key = ':${pAnnot?.peek('name')?.stringValue ?? p.name}';
          _value = _value.replaceFirst(key, '\$${p.name}');
        }
      } else if (p.isNamed) {
        final pAnnot = _getQueryParamAnnotation(p);
        if (pAnnot != null) {
          query[pAnnot?.peek('name')?.stringValue ?? p.name] = p.name;
        }
      }
    }

    if (query.isNotEmpty) {
      _queryString = '{ ';

      query.forEach((key, val) {
        _queryString += "'$key': '\$$val',";
      });

      _queryString += ' }';
    }
  }

  Expression _generateQuery(MethodElement method, ConstantReader annot) {
    if (null != _queryString && _queryString.isNotEmpty) {
      var code = Code(_queryString);
      var expr = CodeExpression(code);
      return kParamsToQueryUriRef.call([expr]).assignFinal(kQueryStr);
    }

    return null;
  }

  Expression _generateUrl(MethodElement method, ConstantReader annot) {
    if (null != _queryString && _queryString.isNotEmpty)
      return literal('\$$kBaseUrl$_value?\$$kQueryStr').assignFinal(kUrl);

    return literal('\$$kBaseUrl$_value').assignFinal(kUrl);
  }

  Expression _generateVarResponse() =>
      literalNull.assignVar(kResponse, kReflutterResponseRef);

  Expression _generateRequest(MethodElement method, ConstantReader annot) {
    final code = Code("'${annot.peek('method').stringValue}'");
    final annotExpr = CodeExpression(code);
    final params = {kMethod: annotExpr, kUrl: kUrlRef, kHeaders: kHeadersRef};

    for (var p in method.parameters) {
      final pAnnot = _getBodyAnnotation(p);
      if (pAnnot != null) {
        params[kBody] = kJsonRef.property('encode').call([refer(p.name)]);
      }
    }
    return kReflutterRequestRef.call([], params).assignVar(kRequest);
  }

  Expression _generateInterceptRequest() =>
      kRequestRef.assign(kInterceptReqRef.call([kRequestRef]).awaited);

  Expression _generateInterceptResponseReturn(MethodElement m) {
    return kInterceptResRef
        .call([kResponseRef])
        .awaited
        .asA(_genericTypeBuilder(m.returnType))
        .returned;
  }

  Expression _generateSendRequest() => kRequestRef
      .property(kSendMethod)
      .call([const CodeExpression(Code(kClient))])
      .awaited
      .assignFinal(kRawResponse);

  CodeExpression _generateResponseProcess(MethodElement method) {
    final responseType = getResponseType(method.returnType);
    final respTypeName = responseType?.displayName;
    final type = _genericOf(responseType)?.displayName;

    if (!respTypeName.startsWith('ReflutterResponse')) {
      throw Exception(
          'Method return types should be of type ReflutterResponse. Instead, got $respTypeName<$type>');
    }

    String responseCode;
    if (responseType.displayName.contains('List<'))
      responseCode =
          'ReflutterResponse($type.from(json.decode(rawResponse.body) as Iterable), rawResponse)';
    else
      responseCode =
          'ReflutterResponse($type.fromJson(json.decode(rawResponse.body) as Map<String, String>), rawResponse)';
    if (type == 'dynamic') {
      responseCode = 'ReflutterResponse.empty(rawResponse)';
    }

    final block = Block.of([
      Code(
          'if (ReflutterApiDefinition.responseSuccessful(rawResponse)) {response = $responseCode;}'),
      const Code(
          'else {response = ReflutterResponse.error(rawResponse, rawResponse.reasonPhrase);}')
    ]);

    return CodeExpression(block);
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
