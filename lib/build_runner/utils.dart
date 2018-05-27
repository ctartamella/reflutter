import 'package:code_builder/code_builder.dart';

const String kClient = "client";
const String kBaseUrl = "baseUrl";
const String kUrl = "url";
const String kHeaders = "headers";
const String kSerializers = "serializers";
const String kResponse = "response";
const String kRawResponse = "rawResponse";
const String kRequest = "request";
const String kBody = "body";
const String kMethod = "method";
const String kSerializeMethod = "serialize";
const String kDeserializeMethod = "deserialize";
const String kReflutterRequest = "ReflutterRequest";
const String kReflutterResponse = "ReflutterResponse";
const String kInterceptReq = "interceptRequest";
const String kInterceptRes = "interceptResponse";
const String kSendMethod = "send";
const String kError = "error";
const String kType = "type";
const String kResponseSuccessful = "responseSuccessful";
const String kParamsToQueryUri = "paramsToQueryUri";

Reference get kClientRef => refer(kClient);

Reference get kBaseUrlRef => refer(kBaseUrl);

Reference get kUrlRef => refer(kUrl);

Reference get kHeadersRef => refer(kHeaders);

Reference get kSerializersRef => refer(kSerializers);

Reference get kResponseRef => refer(kResponse);

Reference get kRequestRef => refer(kRequest);

Reference get kReflutterRequestRef => refer(kReflutterRequest);

Reference get kReflutterResponseRef => refer(kReflutterResponse);

Reference get kInterceptReqRef => refer(kInterceptReq);

Reference get kInterceptResRef => refer(kInterceptRes);

Reference get kRawResponseRef => refer(kRawResponse);

Reference get kRawResponseBodyRef => refer("$kRawResponse.$kBody");

Reference get kResponseSuccessfulRef => refer(kResponseSuccessful);

Reference get kHttpClientType => refer("Client", "package:http/http.dart");

Reference get kStringType => refer("String");

Reference get kMapType => refer("Map");

Reference get kSerializerType =>
    refer("SerializerRepo", "package/jaguar_serializer/jaguar_serializer.dart");
