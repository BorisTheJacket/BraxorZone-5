import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ClubVenueGateway {
  static Future<bool> isVenueReachable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  static Future<http.Response> dispatchVenueSync(bool useDeepSync, String venueHub) async {
    if (useDeepSync) {
      return await http.get(Uri.parse(venueHub));
    } else {
      return await http.head(Uri.parse(venueHub));
    }
  }
}
