import 'package:shared_preferences/shared_preferences.dart';
import '../utils/club_zone_config.dart';

class ClubSessionStorage {
  static Future<void> saveSessionPath(String sessionToken) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString(ClubZoneConfig.savedSessionTokenKey, sessionToken);
  }

  static Future<String?> fetchSavedSessionPath() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString(ClubZoneConfig.savedSessionTokenKey);
  }

  static Future<void> setMemberClearance(int status) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setInt(ClubZoneConfig.memberClearanceKey, status);
  }

  static Future<bool> isMemberPermitted() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return (storage.getInt(ClubZoneConfig.memberClearanceKey) ?? 0) == 1;
  }

  static Future<bool> isSyncRequested() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return (storage.getInt(ClubZoneConfig.syncRequestedKey) ?? 0) == 1;
  }

  static Future<bool> hasSyncResponse() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return (storage.getInt(ClubZoneConfig.syncResponseKey) ?? 0) == 1;
  }
}
