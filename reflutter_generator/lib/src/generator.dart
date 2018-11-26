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

    //return '${clazz.accept(DartEmitter())}';
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

  Code _generateMethodBlock(MethodElement m, ConstantReader methodAnnot) {
    var list = <Code>[];

    var url = _parseUrl(m, methodAnnot);
    var queryString = _parseParameters(m, methodAnnot);
    if (queryString != '')
      list.add(_generateQuery(m, methodAnnot, queryString).statement);

    list.add(_generateUrl(m, methodAnnot, queryString, url).statement);
    list.add(_generateRequest(m, methodAnnot).statement);
    list.add(_generateInterceptRequest(m, methodAnnot).statement);
    list.add(_generateSendRequest().statement);
    list.add(_generateErrorCheck());
    list.add(_generateResponseProcess(m).code);
    list.add(_generateReturnValue(m, methodAnnot).statement);

    return Block.of(list);
  }

  String _parseUrl(MethodElement method, ConstantReader annot) {
    var url = '${annot.read('url').stringValue}';

    for (var p in method.parameters) {
      if (p.isPositional) {
        final pAnnot = _getParamAnnotation(p);
        if (pAnnot != null) {
          final key = ':${pAnnot?.peek('name')?.stringValue ?? p.name}';
          url = url.replaceFirst(key, '\$${p.name}');
        }
      } 
    }

    return url;
  }

  String _parseParameters(MethodElement method, ConstantReader annot) {
    var query = {};
    for (var p in method.parameters) {
      if (p.isNamed) {
        final pAnnot = _getQueryParamAnnotation(p);
        if (pAnnot != null) {
          query[pAnnot?.peek('name')?.stringValue ?? p.name] = p.name;
        }
      }
    }

    var queryString = '';
    if (query.isNotEmpty) {
      queryString = '{ ';

      query.forEach((key, val) {
        queryString += "'$key': '\$$val',";
      });

      queryString += ' }';
    }

    return queryString;
  }

  Expression _generateQuery(MethodElement method, ConstantReader annot, String queryString) {
    if (null != queryString && queryString.isNotEmpty) {
      var code = Code(queryString);
      var expr = CodeExpression(code);
      return kParamsToQueryUriRef.call([expr]).assignFinal(kQueryStr);
    }

    return null;
  }

  Expression _generateUrl(MethodElement method, ConstantReader annot, String queryString, String url) {
    if (null != queryString && queryString.isNotEmpty)
      return literal('\$$kBaseUrl$url?\$$kQueryStr').assignFinal(kUrl);

    return literal('\$$kBaseUrl$url').assignFinal(kUrl);
  }

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

  Expression _generateInterceptRequest(MethodElement method, ConstantReader annot) =>
    kRequestRef.assign(kInterceptReqRef.call([kRequestRef]).awaited);

  Expression _generateSendRequest() => kRequestRef
      .property(kSendMethod)
      .call([const CodeExpression(Code(kClient))])
      .awaited
      .assignFinal(kRawResponse);

  Code _generateErrorCheck() {
    return const Code('''if (!ReflutterApiDefinition.responseSuccessful(rawResponse)) {
      return ReflutterResponse(null, rawResponse);
    }''');
  }

  Expression _generateResponseProcess(MethodElement method) {
    final responseType = getResponseType(method.returnType);
    final respTypeName = responseType?.displayName;
    final type = _genericOf(responseType)?.displayName;

    if (!respTypeName.startsWith('ReflutterResponse')) {
      throw Exception(
          'Method return types should be of type ReflutterResponse. Instead, got $respTypeName<$type>');
    }

    String response;
    if (responseType.displayName.contains('List<'))
      response =
          'ReflutterResponse($type.from(json.decode(rawResponse.body) as Iterable), rawResponse);';
    else
      response =
          'ReflutterResponse($type.fromJson(json.decode(rawResponse.body) as Map<String, dynamic>), rawResponse);';
    if (type == 'dynamic') {
      response = 'ReflutterResponse.empty(rawResponse);';
    }

    var resp = CodeExpression(Code(response));
    return resp.assignFinal(kResponse);
  }

  Expression _generateReturnValue(MethodElement method, ConstantReader annot) =>
    kInterceptResRef.call([kResponseRef]).awaited.returned;

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
