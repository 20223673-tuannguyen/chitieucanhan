// ignore_for_file: file_names

import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/features/auth/repository/authRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Authcubit extends Cubit<Authstate> {
  Authcubit() : super(Authstate.unAuthenticated());

  final Authrepo _authrepo = Authrepo();

  Future<void> loginWithNoAccount() async {
    try {
      await _authrepo.loginWithNoAccount();
      emit(Authstate.authenticated());
    } catch (e) {
      emit(Authstate.error(e.toString()));
    }
  }
}
