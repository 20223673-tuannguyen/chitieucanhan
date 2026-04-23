enum AuthStatus { unAuthenticated, guest, authenticated, loading, error }

class Authstate {
  final AuthStatus authStatus;
  final String? errorMessage;

  Authstate({required this.authStatus, this.errorMessage});

  factory Authstate.unAuthenticated() =>
      Authstate(authStatus: AuthStatus.unAuthenticated);
  factory Authstate.authenticated() =>
      Authstate(authStatus: AuthStatus.authenticated);
  factory Authstate.loading() => Authstate(authStatus: AuthStatus.loading);
  factory Authstate.error(String message) =>
      Authstate(authStatus: AuthStatus.error, errorMessage: message);
}
