import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
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
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

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

  @override
  Future<T?> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        "/api/auth/registeur",
        data: {"username": email, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;

        // Save token and userId in Hive
        await _box.put('authToken', resData['access_token']);
        await _box.put('userId', resData['data']['id']);

        // Get auth cookie (optional, for debug or further usage)
        var cookieValue = await getAuthCookie();
        if (cookieValue != null && cookieValue.isNotEmpty) {
          await _box.put('cookie', cookieValue);
          print("Cookie saved: $cookieValue");
        } else {
          print("No cookie to save");
        }
        // ✅ Initialize socket automatically after login
        await SocketIOManager.instance.initialize(
          url: _dio.options.baseUrl, // replace with your Socket.IO URL
        );

        return fromJson(resData['data']);
      } else {
        print("Registration failed: ${response.statusCode}");
        print("Response: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Status code: ${e.response!.statusCode}");
        print("Response: ${e.response!.data}");
      }
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }

  @override
  Future<T?> verifyCode(String code) async {
    try {
      final response = await _dio.post(
        "/api/auth/loginwithcode",
        data: {"code": code},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;

        // Save token and userId in Hive
        await _box.put('authToken', resData['access_token']);
        await _box.put('userId', resData['data']['id']);

        // Get auth cookie (optional, for debug or further usage)
        var cookieValue = await getAuthCookie();
        if (cookieValue != null && cookieValue.isNotEmpty) {
          await _box.put('cookie', cookieValue);
          print("Cookie saved: $cookieValue");
        } else {
          print("No cookie to save");
        }

        return fromJson(resData['data']);
      } else {
        print("Code verification failed: ${response.statusCode}");
        print("Response: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Status code: ${e.response!.statusCode}");
        print("Response: ${e.response!.data}");
      }
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }

  @override
  Future<T?> login(String email, String password) async {
    var b = await Hive.openBox('cookieBox');
    try {
      final response = await _dio.post(
        "/api/auth/login",
        data: {"username": email, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;

        // Save token and userId in Hive
        await _box.put('authToken', resData['access_token']);
        await _box.put('userId', resData['data']['id']);

        // Get auth cookie (optional, for debug or further usage)
        var cookieValue = await getAuthCookie();
        if (cookieValue != null && cookieValue.isNotEmpty) {
          await _box.put('cookie', cookieValue);
          print("Cookie saved: $cookieValue");
        } else {
          print("No cookie to save");
        }

        final savedCookie = await b.get('ZENIFY_SESSION_ID');
        final injected = {
          ...(resData['data'] as Map<String, dynamic>),
          'token': resData['access_token'],
          'cookie': savedCookie,
        };

        print("Injected user map: $injected");

        return fromJson(injected);
      } else {
        print("Login failed: ${response.statusCode}");
        print("Response: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      print("Dio error: ${e.message}");
      if (e.response != null) {
        print("Status code: ${e.response!.statusCode}");
        print("Response: ${e.response!.data}");
      }
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    if (!kIsWeb) await _cookieJar?.deleteAll();
    await _box.delete('ZENIFY_SESSION_ID');
    print("All cookies cleared");
    await _box.clear();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _box.get('authToken') != null;
  }

  @override
  Future<T?> getUserProfile() async {
    final userId = _box.get('userId');
    if (userId == null) return null;

    try {
      final response = await _dio.get("/api/users/$userId");
      if (response.statusCode == 200) return fromJson(response.data);
      return null;
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  // ===== NEW TRAVELLER LOGIN METHODS =====

  @override
  Future<List<Traveller>> fetchTravellersByCode(String code) async {
    try {
      final response = await _dio.get(
        '/api/travellers-mobile',
        queryParameters: {'filters[code]': code},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List results = responseData["results"] ?? [];

        return results.map((data) => Traveller.fromJson(data)).toList();
      } else {
        print("Fetch travellers failed: ${response.statusCode}");
        print("Response: ${response.data}");
        return [];
      }
    } on DioException catch (e) {
      print("Dio error fetching travellers: ${e.message}");
      if (e.response != null) {
        print("Status code: ${e.response!.statusCode}");
        print("Response: ${e.response!.data}");
      }
      return [];
    } catch (e) {
      print("Unexpected error fetching travellers: $e");
      return [];
    }
  }

  @override
  Future<T?> loginWithTraveller(Traveller traveller) async {
    if (traveller.user?.email == null) {
      print("Invalid traveller data: missing email");
      return null;
    }

    try {
      // Clear existing cookies/tokens
      if (!kIsWeb) await _cookieJar?.deleteAll();
      await _box.delete('authToken');
      await _box.delete('userId');

      // Try predefined passwords
      final List<String> passwords = ["Hello@2023", "ZenifyTrip@2024"];

      for (String password in passwords) {
        try {
          final response = await _dio.post(
            '/api/auth/login',
            data: {"username": traveller.user!.email!, "password": password},
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final resData = response.data;

            // Save token and userId in Hive
            await _box.put('authToken', resData['access_token']);
            await _box.put('userId', resData['data']['id']);

            // Get auth cookie
            var cookieValue = await getAuthCookie();
            if (cookieValue != null && cookieValue.isNotEmpty) {
              await _box.put('cookie', cookieValue);
              print("Cookie saved: $cookieValue");
            }

            // Create user object with token and cookie
            final userData = {
              ...(resData['data'] as Map<String, dynamic>),
              'token': resData['access_token'],
              'cookie': cookieValue,
            };

            print("Traveller login successful with password: $password");
            // final savedCookie = await b.get('ZENIFY_SESSION_ID');
            final injected = {
              ...(resData['data'] as Map<String, dynamic>),
              'token': resData['access_token'],
              'cookie': "Cooool",
            };

            print("Injected user map: $injected");

            return fromJson(injected);
          }
        } on DioException catch (e) {
          // Continue to next password if this one fails
          print("Login attempt failed with password $password: ${e.message}");
          continue;
        }
      }

      print(
        "All password attempts failed for traveller: ${traveller.user!.email}",
      );
      return null;
    } catch (e) {
      print("Unexpected error during traveller login: $e");
      return null;
    }
  }

  // -----------------------------
  // Helper methods for cookies
  Future<List<Cookie>> getCookies(String url) async {
    if (_cookieJar == null) return [];
    final uri = Uri.parse(url);
    return await _cookieJar!.loadForRequest(uri);
  }

  Future<String?> getCookieValue(String url, String name) async {
    final cookieValue = await getCookies(url);

    if (cookieValue != null && cookieValue.isNotEmpty) {
      await Hive.box(
        'cookieBox',
      ).put('ZENIFY_SESSION_ID', cookieValue[0].toString());
      print("Cookie saved: $cookieValue");
    }

    if (cookieValue.isEmpty) {
      print("No cookies found for $url");
      return null;
    }

    final cookie = cookieValue.firstWhere(
      (c) => c.name == name,
      orElse: () => Cookie(name, ''),
    );

    print("All cookies: $cookieValue");
    print("Selected cookie: $cookie");

    return cookie.value.isEmpty ? null : cookie.value;
  }

  Future<String?> getAuthCookie() async {
    if (kIsWeb) return null;
    return await getCookieValue(_dio.options.baseUrl, 'authToken');
  }
}
