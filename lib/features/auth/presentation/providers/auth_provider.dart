import 'package:flutter/foundation.dart';

import '../../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.repository});

  final AuthRepository repository;

  bool isLoading = false;
  String? errorMessage;
  String? recoveryMessage;
  Map<String, dynamic>? profile;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.login(email: email, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    profile = null;
    notifyListeners();
  }

  Future<bool> forgotPassword({required String email}) async {
    isLoading = true;
    errorMessage = null;
    recoveryMessage = null;
    notifyListeners();

    try {
      await repository.forgotPassword(email: email);
      recoveryMessage = 'Si el correo existe, recibirás instrucciones para recuperar tu contraseña.';
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
