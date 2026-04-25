import 'dart:convert';

import 'package:http/http.dart' as http;

class GeoCoordinates {
  final double latitude;
  final double longitude;

  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
  });
}

class IpLocationService {
  static const String _endpoint = 'https://api.ipwho.org/me';

  Future<GeoCoordinates?> getApproximateLocation() async {
    try {
      final response = await http
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        return null;
      }

      final success = body['success'] == true;
      final data = body['data'];
      if (!success || data is! Map<String, dynamic>) {
        return null;
      }

      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();

      if (latitude == null || longitude == null) {
        return null;
      }

      return GeoCoordinates(latitude: latitude, longitude: longitude);
    } catch (_) {
      return null;
    }
  }
}
