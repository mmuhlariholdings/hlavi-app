import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Dio HTTP client configuration with interceptors
/// Provides a configured Dio instance for API calls
class DioClient {

  DioClient({this.authToken});
  static const String _baseUrl = 'https://api.github.com';
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  final String? authToken;

  /// Get configured Dio instance
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectionTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    );

    // Add auth token interceptor if token is provided
    if (authToken != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $authToken';
            return handler.next(options);
          },
        ),
      );
    }

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle GitHub API errors
          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            final message = _getErrorMessage(statusCode, error.response!.data);

            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error: message,
                message: message,
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Get user-friendly error message from GitHub API response
  String _getErrorMessage(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized. Please sign in again.';
      case 403:
        if (data is Map && data['message']?.toString().contains('rate limit') == true) {
          return 'GitHub API rate limit exceeded. Please try again later.';
        }
        return 'Access forbidden. Check your permissions.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Invalid request. Please check your input.';
      case 500:
      case 502:
      case 503:
        return 'GitHub server error. Please try again later.';
      default:
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        return 'An error occurred. Please try again.';
    }
  }
}
