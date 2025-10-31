import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

class AuthViewModel {
  final Ref ref;
  AuthViewModel(this.ref);

  Future<void> tryLoadSession() async {
    final repo = ref.read(authRepositoryProvider);
    ref.read(authLoadingProvider.notifier).state = true;
    try {
      final u = await repo.currentUser();
      ref.read(authStateProvider.notifier).state = u;
    } catch (e) {
      // ignore silently if no session
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    try {
      await repo.login(email, password);
      final u = await repo.currentUser();
      ref.read(authStateProvider.notifier).state = u;
      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = "Login failed";
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    try {
      await repo.register(name, email, password);
      final u = await repo.currentUser();
      ref.read(authStateProvider.notifier).state = u;
      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = "Register failed";
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(authStateProvider.notifier).state = null;
  }
}

final authViewModelProvider = Provider<AuthViewModel>(
  (ref) => AuthViewModel(ref),
);
