import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenify_auth/src/config/api_base_url.dart';
import 'package:zenify_auth/zenify_auth.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl<T> implements AuthRepository<T> {
  final Dio _dio;
  final Box _box;
  final T Function(Map<String, dynamic>) fromJson;
  CookieJar? _cookieJar;

  AuthRepositoryImpl({
    required this.fromJson,
    required String baseUrl, // baseUrl is required
    Dio? dio,
    Box? box,
  }) : _dio = dio ?? Dio(),
       _box = box ?? Hive.box('authBox') {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    if (!kIsWeb) {
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // Add auth token to headers automatically
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _box.get('authToken');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }
  // Login method
  @override
  // Future<T?> login(String email, String password) async {
  //   try {
  //     final response = await _dio.post(
  //       "/api/auth/login",
  //       data: {"username": email, "password": password},
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final resData = response.data;

  //       // Save token and userId in Hive
  //       await _box.put('authToken', resData['access_token']);
  //       await _box.put('userId', resData['data']['id']);

  //       // Get auth cookie (optional, for debug or further usage)
  //       var cookieValue = await getAuthCookie();
  //       if (cookieValue != null && cookieValue.isNotEmpty) {
  //         await _box.put('cookie', cookieValue);
  //         print("Cookie saved: $cookieValue");
  //       } else {
  //         print("No cookie to save");
  //       }
  //       // ✅ Initialize socket automatically after login
  //       await SocketIOManager.instance.initialize(
  //         url:
  //             baseUrl, // replace with your Socket.IO URL
  //       );

  //       return fromJson(resData['data']);
  //     } else {
  //       print("Login failed: ${response.statusCode}");
  //       print("Response: ${response.data}");
  //       return null;
  //     }
  //   } on DioException catch (e) {
  //     print("Dio error: ${e.message}");
  //     if (e.response != null) {
  //       print("Status code: ${e.response!.statusCode}");
  //       print("Response: ${e.response!.data}");
  //     }
  //     return null;
  //   } catch (e) {
  //     print("Unexpected error: $e");
  //     return null;
  //   }
  // }

Future<T?> login(String email, String password) async {
  try {
    final response = await _dio.post(
      "/api/auth/login",
      data: {"username": email, "password": password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resData = response.data;

      await _box.put('authToken', resData['access_token']);
      await _box.put('userId', resData['data']['id']);

      var cookieValue = await getAuthCookie();
      if (cookieValue != null && cookieValue.isNotEmpty) {
        await _box.put('cookie', cookieValue);
        print("Cookie saved: $cookieValue");
      }

      // ✅ Use global API Base URL here
      await SocketIOManager.instance.initialize(url: ApiBaseUrl.baseUrl);

      return fromJson(resData['data']);
    } else {
      print("Login failed: ${response.statusCode}");
      return null;
    }
  } on DioException catch (e) {
    print("Dio error: ${e.message}");
    return null;
  } catch (e) {
    print("Unexpected error: $e");
    return null;
  }
}


  @override
  Future<void> logout() async {
    if (!kIsWeb) await _cookieJar?.deleteAll();
    await _box.clear();
  }

  // Check if user is logged in
  @override
  Future<bool> isLoggedIn() async {
    return _box.get('authToken') != null;
  }

  // Get user profile
  @override
  Future<T?> getUserProfile() async {
    final userId = _box.get('userId');
    if (userId == null) return null;

    final response = await _dio.get("/api/users/$userId");
    if (response.statusCode == 200) return fromJson(response.data);
    return null;
  }

  // -----------------------------
  // ✅ New helper: get cookies
  Future<List<Cookie>> getCookies(String url) async {
    if (_cookieJar == null) return [];
    final uri = Uri.parse(url);
    return await _cookieJar!.loadForRequest(uri);
  }

  // Get specific cookie by name
  Future<String?> getCookieValue(String url, String name) async {
    final cookieValue = await getCookies(url);

    if (cookieValue != null && cookieValue.isNotEmpty) {
      await Hive.box(
        'cookieBox',
      ).put('ZENIFY_SESSION_ID', cookieValue[0].toString());
      print("Cookie saddddved: $cookieValue");
    }

    if (cookieValue.isEmpty) {
      print("No cookies found for $url");
      return null;
    }

    // Try to find the cookie by name
    final cookie = cookieValue.firstWhere(
      (c) => c.name == name,
      orElse: () => Cookie(name, ''), // returns an empty cookie if not found
    );

    print("All cookies: $cookieValue");
    print("Selected cookie: $cookie");

    // Return null if the cookie value is empty
    return cookie.value.isEmpty ? null : cookie.value;
  }

  // Get auth token cookie
  Future<String?> getAuthCookie() async {
    if (kIsWeb) return null; // CookieJar doesn't exist on Web
    return await getCookieValue(_dio.options.baseUrl, 'authToken');
  }
}
