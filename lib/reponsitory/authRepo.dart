// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'dart:developer' as developer;

class Authrepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Đăng nhập bằng Email và Password qua Firebase
  Future<UserCredential> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin user vào Hive để hiển thị ở Profile
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          uid: user.uid,
          name: user.displayName ?? user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
          picture: user.photoURL ?? '',
          dateOfBirth: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await Hive.box<UserModel>('userBox').put('currentUser', userModel);
      }

      // Lưu trạng thái đăng nhập vào Local
      await SettingsService.setAppState(true);
      await SettingsService.setAuthMode('firebase');
      
      developer.log('Đăng nhập Firebase thành công: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Lỗi Firebase Login: ${e.code}');
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới qua Firebase
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Lưu thông tin user mới vào Hive
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          uid: user.uid,
          name: user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
          picture: '',
          dateOfBirth: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await Hive.box<UserModel>('userBox').put('currentUser', userModel);
      }

      await SettingsService.setAppState(true);
      await SettingsService.setAuthMode('firebase');

      developer.log('Đăng ký Firebase thành công');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Lỗi Firebase SignUp: ${e.code}');
      rethrow;
    }
  }

  /// Đăng nhập chế độ không tài khoản (Sử dụng dữ liệu cục bộ)
  Future<void> loginWithNoAccount() async {
    try {
      // Tạo user mặc định cho Guest
      final guestUser = UserModel(
        id: 'guest',
        uid: 'guest',
        name: 'Guest User',
        email: 'guest@example.com',
        picture: '',
        dateOfBirth: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await Hive.box<UserModel>('userBox').put('currentUser', guestUser);

      await SettingsService.setAppState(true);
      await SettingsService.setAuthMode('guest');
      developer.log('Đăng nhập Guest thành công');
    } catch (e) {
      developer.log('Lỗi loginWithNoAccount: $e');
      rethrow;
    }
  }

  /// Đăng xuất: Xóa sạch token, Firebase session và đưa người dùng về màn hình đăng nhập
  Future<void> logout() async {
    try {
      // 1. Đăng xuất khỏi Firebase
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      // 2. Xóa toàn bộ dữ liệu trong box jwt và userBox
      await Hive.box('jwt').clear();
      await Hive.box<UserModel>('userBox').clear();

      // 3. Chuyển trạng thái appState về false
      await SettingsService.setAppState(false);
      
      // 4. Reset chế độ auth và đánh dấu vừa đăng xuất
      await SettingsService.setAuthMode('none');
      await SettingsService.setJustLoggedOut(true);
      
      developer.log('Đăng xuất thành công (Firebase & Local)');
    } catch (e) {
      developer.log('Lỗi khi đăng xuất: $e');
      rethrow;
    }
  }
}
