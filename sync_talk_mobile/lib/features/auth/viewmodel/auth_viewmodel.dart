import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'auth_providers.dart';

class AuthViewModel {
  final Ref ref;
  AuthViewModel(this.ref);

  /// Login user
  Future<void> login(String email, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final repo = ref.read(authRepositoryProvider);
      // Use NAMED parameters
      final result = await repo.login(email: email, password: password);

      // Store user state
      ref.read(authStateProvider.notifier).state = result['user'];
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Register new user
  Future<void> register(String name, String email, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final repo = ref.read(authRepositoryProvider);
      // Use NAMED parameters
      final result = await repo.register(
        name: name,
        email: email,
        password: password,
      );

      // Store user state
      ref.read(authStateProvider.notifier).state = result['user'];
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Login with Google
  Future<void> loginWithGoogle(String idToken) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.loginWithGoogle(idToken);

      // Store user state
      ref.read(authStateProvider.notifier).state = result['user'];
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Get current user
  Future<void> getCurrentUser() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.currentUser();
      ref.read(authStateProvider.notifier).state = user;
    } catch (e) {
      ref.read(authStateProvider.notifier).state = null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      ref.read(authStateProvider.notifier).state = null;
    }
  }

  /// Check if logged in
  Future<bool> checkLoginStatus() async {
    return await ref.read(authRepositoryProvider).isLoggedIn();
  }
}

final authViewModelProvider = Provider((ref) => AuthViewModel(ref));
