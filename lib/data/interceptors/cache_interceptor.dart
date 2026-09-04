// import 'dart:async';

// import 'package:chopper/chopper.dart';
// import 'package:data_repository/data_repository.dart';
// import 'package:flutter/foundation.dart';

// import '../cache_manager.dart';

// class CacheInterceptor  extends ApiInterceptor {
//   final CacheManager _cache = CacheManager();

//   @override
//   FutureOr<Request> onRequest(Request request) {
//     debugPrint('in cach interceptor request ${request.url}');
//     interpretRequest(request.url.toString());
//     return request;
//   }

//   Future interpretRequest(String url) async {
//     dynamic data = await _cache.getCachedData(url);
//     if(data != null ){
//       throw HasCachedData(data);
//     }

//   }

//   @override
//   FutureOr<Response> onResponse(Response response) {
//     debugPrint('in cache interceptor response ${response.body}');
//     return response;
//   }

// }

// class HasCachedData implements Exception {
//   final String jsonData ;

//   HasCachedData(this.jsonData);

//   @override
//   String toString() =>jsonData;
// }
