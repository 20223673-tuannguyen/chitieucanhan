// ignore_for_file: file_names

import 'package:hive_flutter/adapters.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';

class Authrepo {
  //get user data from local storage
  Future<void> loginWithNoAccount() async {
    await SettingsService.setAppState(true);
    await SettingsService.setAuthMode('guest');
  }

  // Logout
  Future<void> logout() async {
    // Clear tokens
    final jwtBox = Hive.box('jwt');
    jwtBox.delete('accessToken');
    jwtBox.delete('refreshToken');

    // Keep app state as logged-in (guest) so app stays on main screen
    await SettingsService.setAppState(true);
    await SettingsService.setAuthMode('guest');
    await SettingsService.setJustLoggedOut(true);
  }
}
