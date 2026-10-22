import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  String _name        = '';
  bool   _usePassword = false;
  bool   _hasPassword = false;

  String get name        => _name;
  bool   get usePassword => _usePassword;
  bool   get hasPassword => _hasPassword;
  String get displayName => _name.isEmpty ? 'Player' : _name;

  Future<void> load() async {
    _name        = await AuthService.getUserName();
    _usePassword = await AuthService.usePasswordOnLaunch();
    _hasPassword = (await AuthService.getPassword()) != null;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    String? password,
    bool usePassword = false,
  }) async {
    await AuthService.register(
        name: name, password: password, usePassword: usePassword);
    _name        = name.trim();
    _hasPassword = password != null && password.isNotEmpty;
    _usePassword = usePassword;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    final p = await AuthService.getPassword();
    await AuthService.register(
        name: name,
        password: p,
        usePassword: _usePassword);
    _name = name.trim();
    notifyListeners();
  }

  Future<void> savePassword(String password) async {
    await AuthService.savePassword(password);
    _hasPassword = true;
    _usePassword = true;
    notifyListeners();
  }

  Future<void> removePassword() async {
    await AuthService.removePassword();
    _hasPassword = false;
    _usePassword = false;
    notifyListeners();
  }

  Future<void> toggleUsePassword(bool value) async {
    await AuthService.setUsePassword(value);
    _usePassword = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _name        = '';
    _usePassword = false;
    _hasPassword = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await AuthService.deleteAccount();
    _name        = '';
    _usePassword = false;
    _hasPassword = false;
    notifyListeners();
  }
}
