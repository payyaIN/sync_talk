// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/auth_repository.dart';

// final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepository());

// /// Global auth state for current user
// final authStateProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// /// Helper provider to easily read userId
// final currentUserIdProvider = Provider<String?>((ref) {
//   final user = ref.watch(authStateProvider);
//   return user?['_id'];
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authStateProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
); // current user
final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/auth_repository.dart';

// final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepository());

// /// Global auth state for current user
// final authStateProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// /// Helper provider to easily read userId
// final currentUserIdProvider = Provider<String?>((ref) {
//   final user = ref.watch(authStateProvider);
//   return user?['_id'];
// });
