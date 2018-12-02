import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Typedef to define a [RequestInterceptor] method.
typedef RequestInterceptor<T> = FutureOr<ReflutterRequest<T>> Function(
    ReflutterRequest<T> request);

/// Typedef to define a [ResponseInterceptor] method.
typedef ResponseInterceptor<T> = FutureOr<ReflutterResponse<T>> Function(
    ReflutterResponse<T> response);

/// Convert a [Map<String, String>] to a formatted query
/// string for use in a URL.
String paramsToQueryUri(Map<String, String> params) {
  final pairs = <List<String>>[];
  params.forEach((key, value) {
    if (value != null && value.isNotEmpty && value != 'null')
      pairs.add(
          [Uri.encodeQueryComponent(key), Uri.encodeQueryComponent(value)]);
  });

  return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
}

/// The main HTTP API defintion annotation.  This should be used
/// to designate a class that should be processed by Reflutter's
/// code generation scripts.
class ReflutterHttp {
  /// The name of the API class that will be created.
  final String name;

  /// The default constructor.
  /// [name] -  Any string to define the name of your API.
  const ReflutterHttp({this.name});
}

class _Req {
  final String method;
  final String url;

  const _Req(this.method, this.url);
}

/// Defines an annotation to specify a parameter to be taken from the header
class Param {
  /// The name of the parameter.
  final String name;

  /// The default constructor.  Takes the parameter name as an argument.
  const Param([this.name]);
}

/// Defines a method parameter as coming from the query string.
class QueryParam {
  /// The name of the parameter in the query string.
  final String name;

  /// Default const constructor.  Takes the parameter name as an argument.
  const QueryParam([this.name]);
}

/// Annotation to define a body parameter.
/// Usage:
/// @Post('/users')
/// Future<ReflutterResponse<User>> postUser(@Body() User user);
class Body {
  /// Default const constructor
  const Body();
}

/// Annotation to define a method as a GET request.
class Get extends _Req {
  /// Default const constructor.
  /// Takes the URL path as a parameter.  Defaults to ['/']
  const Get([String url = '/']) : super('GET', url);
}

/// Annotation to define a method as a POST request.
class Post extends _Req {
  /// Default const constructor.
  /// Takes the URL path as a parameter.  Defaults to ['/']
  const Post([String url = '/']) : super('POST', url);
}

/// Annotation to define a method as a PUT request.
class Put extends _Req {
  /// Default const constructor.
  /// Takes the URL path as a parameter.  Defaults to ['/']
  const Put([String url = '/']) : super('PUT', url);
}

/// Annotation to define a method as a Delete request.
class Delete extends _Req {
  /// Default const constructor.
  /// Takes the URL path as a parameter.  Defaults to ['/']
  const Delete([String url = '/']) : super('DELETE', url);
}

/// Annotation to define a method as a PATCH request.
class Patch extends _Req {
  /// Default const constructor.
  /// Takes the URL path as a parameter.  Defaults to ['/']
  const Patch([String url = '/']) : super('PATCH', url);
}

/// Defines the default wrapper for responses from the Reflutter generated API.
/// This should be used for all API calls and should wrap whatver object type [T]
/// that you expect from the call.
class ReflutterResponse<T> {
  final T body;
  final http.Response rawResponse;
  final String errorMessage;

  /// Generate a response for the given body and raw HTTP response.
  ReflutterResponse(this.body, this.rawResponse) : errorMessage = null;

  ReflutterResponse.empty(this.rawResponse)
      : body = null,
        errorMessage = null;

  /// Generates a response indicating an error condition
  /// with the given response.
  ReflutterResponse.error(this.rawResponse, this.errorMessage) : body = null;

  /// Defines whether the response indicates success.
  bool isSuccessful() =>
      rawResponse.statusCode >= 200 && rawResponse.statusCode < 300;

  @override
  String toString() => 'RefitResponse($body)';
}

/// This class is not really intended for external use.  It is public
/// only because it will get used by generated code.
class ReflutterRequest<T> {
  /// The wrapped body object.
  final String body;

  /// The method used for the API call such as Get, Post, etc.
  final String method;

  /// The url of the API call.
  final String url;

  /// Any headers being sent during the call.
  final Map<String, String> headers;

  /// Default constructor use to specify all parameters.
  ReflutterRequest({this.method, this.headers, this.body, url})
      : url = url.toString();

  /// Initiate the call to the API endpoint using the specified
  /// [http.Client].  Returns an [http.Response] asynchronously.
  Future<http.Response> send(http.Client client) async {
    switch (method) {
      case 'POST':
        return client.post(url, headers: headers, body: body);
      case 'PUT':
        return client.put(url, headers: headers, body: body);
      case 'PATCH':
        return client.patch(url, headers: headers, body: body);
      case 'DELETE':
        return client.delete(url, headers: headers);
      default:
        return client.get(url, headers: headers);
    }
  }
}

/// The base class for all API definition objects.  This is used by
/// generated code and is not neccessarily meant for public use.  When
/// implementors decorate a class with the [ReflutterHttp] attribute, a
/// partial instance of that class is generated which subclasses this
/// class.  Base class methods from this will be used to generate the
/// backing methods.
abstract class ReflutterApiDefinition {
  /// The base URL for the REST api.
  final String baseUrl;

  /// Headers to be sent along with each request.
  final Map<String, String> headers;

  /// The HTTP client which will be used for connections.
  final http.Client client;

  /// The main constructor that gets called with some default specified for brevity.
  ReflutterApiDefinition(this.client, this.baseUrl, Map<String, String> headers)
      : headers = headers ?? {'content-type': 'application/json'};

  /// The [List] of [RequestInterceptor] objects to use when
  /// processing requests.
  final List<RequestInterceptor> requestInterceptors = [];

  /// The [List] of [ResponseInterceptor] objects to use when
  /// processing requests.
  final List<ResponseInterceptor> responseInterceptors = [];

  /// Allows for requests to be intercepted prior to submission to the REST
  /// endpoint. This can be used to supplement a request with data, for instance
  /// injecting bearer tokens or other authentication.
  ///
  /// Calls all [RequestInterceptor] objects that have been added to
  /// [this.requestInterceptor] at the time of the request.  Each successive
  /// call gets the object as returned from the previous [RequestInterceptor]
  /// and is similar to a pipeline.
  @protected
  FutureOr<ReflutterRequest> interceptRequest(ReflutterRequest request) async {
    var localreq = request;
    for (var i in requestInterceptors) {
      localreq = await i(localreq);
    }
    return localreq;
  }

  /// Allows for responses to be intercepted prior to processing of the data.
  /// This can be used to add custom error handling or logging or any number
  /// of post-response actions as needed by the user.
  ///
  /// Calls all [ResponseInterceptor] objects that have been added to
  /// [this.responseInterceptor] at the time of the response.  Each successive
  /// call gets the object as returned from the previous [ResponseInterceptor]
  /// and is similar to a pipeline.
  @protected
  FutureOr<ReflutterResponse<T>> interceptResponse<T>(
      ReflutterResponse<T> response) async {
    var localresponse = response;
    for (var i in responseInterceptors) {
      localresponse = await i(localresponse) as ReflutterResponse<T>;
    }
    return localresponse;
  }

  static bool responseSuccessful(http.Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;
}
