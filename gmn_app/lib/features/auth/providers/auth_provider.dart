import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/models/user.dart';

const bool _useMockData = true;

// Mock user for demo
final _mockUser = User(
  id: 'user-1',
  email: 'samerr@gmn.com',
  name: 'Samer R',
  role: 'dispatcher',
  isActive: true,
  createdAt: DateTime.now().subtract(const Duration(days: 180)),
  updatedAt: DateTime.now(),
);

// Auth state provider - tracks the current user
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<User?>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthStateNotifier(repository);
    });

// Current user provider - convenience accessor
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

class AuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initAuth();
  }

  Future<void> _initAuth() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getStoredUser();
        if (user != null) {
          state = AsyncValue.data(user);
          // Optionally refresh user data from server
          _refreshUser();
        } else {
          state = const AsyncValue.data(null);
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _refreshUser() async {
    if (_useMockData) return;

    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (_) {
      // Keep the stored user if refresh fails
    }
  }

  Future<void> login({required String email, required String password}) async {
    if (_useMockData) {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncValue.data(_mockUser);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final user = await _repository.updateProfile(
        name: name,
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_useMockData) {
      state = const AsyncValue.data(null);
      return;
    }

    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refresh() async {
    if (state.hasValue && state.value != null) {
      await _refreshUser();
    }
  }
}
