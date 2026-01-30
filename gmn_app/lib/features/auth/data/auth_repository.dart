import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import 'models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ApiClient(),
    secureStorage: const FlutterSecureStorage(),
  );
});

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required FlutterSecureStorage secureStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage;

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: LoginRequest(email: email, password: password).toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? role,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: RegisterRequest(
        email: email,
        password: password,
        name: name,
        role: role,
      ).toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Get current user from API
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return User.fromJson(response.data['user']);
  }

  /// Update current user profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (currentPassword != null) data['currentPassword'] = currentPassword;
    if (newPassword != null) data['newPassword'] = newPassword;

    final response = await _apiClient.patch(ApiEndpoints.me, data: data);
    final user = User.fromJson(response.data['user']);
    await _saveUser(user);
    return user;
  }

  /// Logout and clear stored data
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored user
  Future<User?> getStoredUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  /// Save authentication data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _secureStorage.write(
      key: AppConstants.tokenKey,
      value: authResponse.token,
    );
    await _saveUser(authResponse.user);
  }

  /// Save user data
  Future<void> _saveUser(User user) async {
    await _secureStorage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }
}
