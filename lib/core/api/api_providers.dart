import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import 'dio_client.dart';
import 'github_api_client.dart';

/// Provider for DioClient with automatic auth token injection
/// Watches auth state and recreates client when token changes
final dioClientProvider = Provider<DioClient>((ref) {
  final authState = ref.watch(authStateProvider);
  final accessToken = authState.token?.accessToken;

  return DioClient(authToken: accessToken);
});

/// Provider for GithubApiClient
/// Uses the authenticated Dio client
final githubApiClientProvider = Provider<GithubApiClient>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GithubApiClient(dioClient.dio);
});
