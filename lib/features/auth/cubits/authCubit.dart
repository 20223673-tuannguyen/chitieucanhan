import 'package:btl/app/services/Local/settings_service.dart';
import 'package:btl/features/auth/cubits/authState.dart';
import 'package:btl/features/auth/repository/authRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Authcubit extends Cubit<Authstate> {
  Authcubit() : super(
    SettingsService.getAppState() 
      ? Authstate.authenticated() 
      : Authstate.unAuthenticated()
  );

  final Authrepo _authrepo = Authrepo();

  // Đăng nhập bằng Firebase
  Future<void> loginWithFirebase(String email, String password) async {
    emit(Authstate.loading());
    try {
      await _authrepo.loginWithEmail(email, password);
      emit(Authstate.authenticated());
    } catch (e) {
      emit(Authstate.error(e.toString()));
    }
  }

  // Đăng ký bằng Firebase
  Future<void> signUpWithFirebase(String email, String password) async {
    emit(Authstate.loading());
    try {
      await _authrepo.signUpWithEmail(email, password);
      emit(Authstate.authenticated());
    } catch (e) {
      emit(Authstate.error(e.toString()));
    }
  }

  Future<void> loginWithNoAccount() async {
    try {
      await _authrepo.loginWithNoAccount();
      emit(Authstate.authenticated());
    } catch (e) {
      emit(Authstate.error(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authrepo.logout();
      emit(Authstate.unAuthenticated());
    } catch (e) {
      emit(Authstate.error(e.toString()));
    }
  }
}
