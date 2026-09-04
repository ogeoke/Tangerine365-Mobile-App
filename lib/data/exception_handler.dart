// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';

// import 'package:sevenup_mobile/models/error_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart';

// import 'interceptors/auth_interceptor.dart';
// import 'interceptors/connection_interceptor.dart';

// mixin ExceptionHandler {
//   ErrorModel formatErrorMessage(dynamic error) {
//     ErrorModelBuilder errorModel = ErrorModelBuilder();
//     if (error is NoInternetException) {
//       errorModel.message =
//           'You are currently offline please check connection and try again';
//       errorModel.code = 'NoInternetException';
//     } else if (error is SocketException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'SocketException';
//     } else if (error is FormatException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'FormatException';
//     } else if (error is ClientException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'ClientException';
//     } else if (error is MissingPluginException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'MissingPluginException';
//     } else if (error is NetworkImageLoadException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'SocketException';
//     } else if (error is PlatformException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'PlatformException';
//     } else if (error is CertificateException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'CertificateException';
//     } else if (error is HttpException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'HttpException';
//     } else if (error is FileSystemException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'FileSystemException';
//     } else if (error is HandshakeException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'HandshakeException';
//     } else if (error is HttpException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'HttpException';
//     } else if (error is IsolateSpawnException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       // errorModel.code = 'IsolateSpawnException';
//     } else if (error is ProcessException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'ProcessException';
//     } else if (error is RedirectException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'RedirectException';
//     } else if (error is TlsException) {
//       errorModel.message = 'SSL error occured ${error.message ?? ''}';
//       errorModel.code = 'TlsException';
//     } else if (error is TimeoutException) {
//       errorModel.message =
//           'Connection Timed out please check your internet connection';
//       errorModel.code = 'TimeoutException';
//     } else if (error is SignalException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'SignalException';
//     } else if (error is StdinException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'StdinException';
//     } else if (error is WebSocketException) {
//       errorModel.message =
//           'Could not connect to the server please check your internet connection';
//       errorModel.code = 'WebSocketException';
//     } else if (error is ExpiredAuth) {
//       errorModel.message = 'Your session has expired';
//       errorModel.code = 'ExpiredAuth';
//     } else {
//       errorModel.message = 'Oops, Something went wrong';
//       errorModel.code = 'UNKNOWN';
//     }
//     return errorModel.build();
//   }
// }
