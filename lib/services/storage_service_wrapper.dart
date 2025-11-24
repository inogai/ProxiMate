import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/profile.dart';
import '../utils/toast_utils.dart';

/// Wrapper for storage operations with error handling and toast notifications
class StorageServiceWrapper {
  final BuildContext context;
  late final StorageService _storage;
  late final ApiService _apiService;

  StorageServiceWrapper(this.context) {
    _storage = Provider.of<StorageService>(context, listen: false);
    _apiService = ApiService();
  }

  /// Save user name with error handling
  Future<bool> saveUserName(String userName) async {
    try {
      await _storage.saveUserName(userName);
      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Profile created successfully!');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(
          context,
          'Failed to create profile: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Save user ID directly for debugging
  Future<bool> saveUserId(int userId) async {
    try {
      // Set the API user ID directly in storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_user_id', userId.toString());

      // Reload the user profile to update the in-memory value
      await _storage.loadUserProfile();

      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Debug user ID set successfully!');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'Failed to set user ID: ${e.toString()}');
      }
      return false;
    }
  }

  /// Update profile with error handling
  Future<bool> updateProfile({
    String? school,
    String? major,
    String? interests,
    String? background,
    String? profileImagePath,
  }) async {
    try {
      await _storage.updateProfile(
        school: school,
        major: major,
        interests: interests,
        background: background,
        profileImagePath: profileImagePath,
      );
      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Profile updated successfully!');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(
          context,
          'Failed to update profile: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Test API connection
  Future<bool> testApiConnection() async {
    try {
      final isHealthy = await _apiService.checkHealth();
      if (context.mounted) {
        if (isHealthy) {
          ToastUtils.showSuccess(context, 'API connection successful!');
        } else {
          ToastUtils.showError(context, 'API server is not responding');
        }
      }
      return isHealthy;
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'API connection failed: ${e.toString()}');
      }
      return false;
    }
  }

  /// Get current profile
  Profile? get currentProfile => _storage.currentProfile;

  /// Check if user exists
  bool get hasUser => _storage.hasUser;

  /// Clear profile with error handling
  Future<bool> clearProfile() async {
    try {
      await _storage.clearProfile();
      if (context.mounted) {
        ToastUtils.showInfo(context, 'Profile cleared successfully');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(
          context,
          'Failed to clear profile: ${e.toString()}',
        );
      }
      return false;
    }
  }
}
