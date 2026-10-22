import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static const _kName        = 'user_name';
  static const _kRegistered  = 'is_registered';
  static const _kPassword    = 'app_password';
  static const _kUsePassword = 'use_password';

  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  static Future<bool>    isRegistered()         async => (await _p).getBool(_kRegistered) ?? false;
  static Future<String>  getUserName()           async => (await _p).getString(_kName) ?? '';
  static Future<bool>    usePasswordOnLaunch()   async => (await _p).getBool(_kUsePassword) ?? false;
  static Future<String?> getPassword()           async => (await _p).getString(_kPassword);

  static Future<void> register({
    required String name,
    String? password,
    bool usePassword = false,
  }) async {
    final p = await _p;
    await p.setString(_kName, name.trim());
    await p.setBool(_kRegistered, true);
    if (password != null && password.isNotEmpty) {
      await p.setString(_kPassword, password);
    }
    await p.setBool(_kUsePassword, usePassword);
  }

  static Future<void> savePassword(String password) async {
    final p = await _p;
    await p.setString(_kPassword, password);
    await p.setBool(_kUsePassword, true);
  }

  static Future<void> removePassword() async {
    final p = await _p;
    await p.remove(_kPassword);
    await p.setBool(_kUsePassword, false);
  }

  static Future<void> setUsePassword(bool value) async =>
      (await _p).setBool(_kUsePassword, value);

  static Future<void> logout() async {
    final p = await _p;
    await p.setBool(_kRegistered, false);
    await p.remove(_kName);
    await p.remove(_kPassword);
    await p.setBool(_kUsePassword, false);
  }

  static Future<void> deleteAccount() async =>
      (await SharedPreferences.getInstance()).clear();
}
