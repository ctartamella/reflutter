import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:meta/meta.dart';

typedef FutureOr<ReflutterRequest> RequestInterceptor(ReflutterRequest request);
typedef FutureOr<ReflutterResponse> ResponseInterceptor(
    ReflutterResponse response);

class ReflutterHttp {
  final String name;

  const ReflutterHttp({this.name});
}

class Req {
  final String method;
  final String url;

  const Req(this.method, this.url);
}

class Param {
  final String name;

  const Param([this.name]);
}

class QueryParam {
  final String name;

  const QueryParam([this.name]);
}

class Body {
  const Body();
}

class Get extends Req {
  const Get([String url = "/"]) : super("GET", url);
}

class Post extends Req {
  const Post([String url = "/"]) : super("POST", url);
}

class Put extends Req {
  const Put([String url = "/"]) : super("PUT", url);
}

class Delete extends Req {
  const Delete([String url = "/"]) : super("DELETE", url);
}

class Patch extends Req {
  const Patch([String url = "/"]) : super("PATCH", url);
}

class ReflutterResponse<T> {
  final T body;
  final http.Response rawResponse;

  ReflutterResponse(this.body, this.rawResponse);
  ReflutterResponse.error(this.rawResponse) : body = null;

  bool isSuccessful() =>
      rawResponse.statusCode >= 200 && rawResponse.statusCode < 300;

  String toString() => "RefitResponse($body)";
}

class ReflutterRequest<T> {
  T body;
  String method;
  String url;
  Map<String, String> headers;

  ReflutterRequest({this.method, this.headers, this.body, this.url});

  Future<http.Response> send(http.Client client) async {
    switch (method) {
      case "POST":
        return client.post(url, headers: headers, body: body);
      case "PUT":
        return client.put(url, headers: headers, body: body);
      case "PATCH":
        return client.patch(url, headers: headers, body: body);
      case "DELETE":
        return client.delete(url, headers: headers);
      default:
        return client.get(url, headers: headers);
    }
  }
}

abstract class ReflutterApiDefinition {
  final String baseUrl;
  final Map headers;
  final http.Client client;
  final SerializerRepo serializers;

  ReflutterApiDefinition(
      this.client, this.baseUrl, Map headers, SerializerRepo serializers)
      : headers = headers ?? {'content-type': 'application/json'},
        serializers = serializers ?? new JsonRepo();

  final List<RequestInterceptor> requestInterceptors = [];
  final List<ResponseInterceptor> responseInterceptors = [];

  @protected
  FutureOr<ReflutterRequest> interceptRequest(ReflutterRequest request) async {
    for (var i in requestInterceptors) {
      request = await i(request);
    }
    return request;
  }

  @protected
  FutureOr<ReflutterResponse> interceptResponse(
      ReflutterResponse response) async {
    for (var i in responseInterceptors) {
      response = i(response);
    }
    return response;
  }
}
