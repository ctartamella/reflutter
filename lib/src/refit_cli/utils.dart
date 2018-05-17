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
const String kJaguarRequest = "JaguarRequest";
const String kJaguarResponse = "JaguarResponse";
const String kInterceptReq = "interceptRequest";
const String kInterceptRes = "interceptResponse";
const String kSendMethod = "send";
const String kError = "error";
const String kType = "type";
const String kResponseSuccessful = "responseSuccessful";
const String kParamsToQueryUri = "paramsToQueryUri";

ReferenceBuilder get kClientRef => reference(kClient);

ReferenceBuilder get kBaseUrlRef => reference(kBaseUrl);

ReferenceBuilder get kUrlRef => reference(kUrl);

ReferenceBuilder get kHeadersRef => reference(kHeaders);

ReferenceBuilder get kSerializersRef => reference(kSerializers);

ReferenceBuilder get kResponseRef => reference(kResponse);

ReferenceBuilder get kRequestRef => reference(kRequest);

ReferenceBuilder get kJaguarRequestRef => reference(kJaguarRequest);

ReferenceBuilder get kJaguarResponseRef => reference(kJaguarResponse);

ReferenceBuilder get kInterceptReqRef => reference(kInterceptReq);

ReferenceBuilder get kInterceptResRef => reference(kInterceptRes);

ReferenceBuilder get kRawResponseRef => reference(kRawResponse);

ReferenceBuilder get kRawResponseBodyRef => reference("$kRawResponse.$kBody");

ReferenceBuilder get kResponseSuccessfulRef => reference(kResponseSuccessful);

TypeBuilder get kHttpClientType => new TypeBuilder("Client");

TypeBuilder get kStringType => new TypeBuilder("String");

TypeBuilder get kMapType => new TypeBuilder("Map");

TypeBuilder get kSerializerType => new TypeBuilder("SerializerRepo");