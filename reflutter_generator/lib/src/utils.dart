// ignore_for_file: public_member_api_docs

import 'package:code_builder/code_builder.dart';

const String kClient = 'client';
const String kBaseUrl = 'baseUrl';
const String kUrl = 'url';
const String kHeaders = 'headers';
const String kResponse = 'response';
const String kRawResponse = 'rawResponse';
const String kRequest = 'request';
const String kBody = 'body';
const String kMethod = 'method';
const String kReflutterRequest = 'ReflutterRequest';
const String kInterceptReq = 'interceptRequest';
const String kInterceptRes = 'interceptResponse';
const String kSendMethod = 'send';
const String kParamsToQueryUri = 'paramsToQueryUri';

Reference get kClientRef => refer(kClient);
Reference get kUrlRef => refer(kUrl);
Reference get kHeadersRef => refer(kHeaders);
Reference get kResponseRef => refer(kResponse);
Reference get kRequestRef => refer(kRequest);
Reference get kReflutterRequestRef => refer(kReflutterRequest);
Reference get kInterceptReqRef => refer(kInterceptReq);
Reference get kInterceptResRef => refer(kInterceptRes);
Reference get kHttpClientType => refer('Client', 'package:http/http.dart');
Reference get kStringType => refer('String');
Reference get kMapType => refer('Map');
Reference get kJsonRef => refer('json', 'dart:convert');
