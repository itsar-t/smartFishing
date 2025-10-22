import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleWeatherService {
  GoogleWeatherService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _host = 'weather.googleapis.com';
  static const _daysPath = '/v1/forecast/days:lookup';
  static const _hoursPath = '/v1/forecast/hours:lookup';

  String get _apiKey {
    // Lägg API-nyckeln i .env (API_KEY=xxxx) eller i din säkra config
    final key = dotenv.env['GOOGLE_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('GOOGLE_WEATHER_API_KEY saknas. Lägg den i .env.');
    }
    return key;
  }

  Future<Map<String, dynamic>> getDailyForecast({
    required double lat,
    required double lon,
    int days = 5,
    String unitsSystem = 'METRIC', // METRIC eller IMPERIAL
    String languageCode = 'sv-SE',
  }) async {
    final uri = Uri.https(_host, _daysPath, {
      'key': _apiKey,
      'location.latitude': lat.toString(),
      'location.longitude': lon.toString(),
      'days': days.toString(),
      'unitsSystem': unitsSystem,
      'languageCode': languageCode,
      // tips: du kan även använda pageSize/pageToken om du vill paginera
    });

    final res = await _client.get(
      uri,
      headers: {
        // säkrare än query-param enligt Google, men båda funkar
        'x-goog-api-key': _apiKey,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Weather API fel ${res.statusCode}: ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHourlyForecast({
    required double lat,
    required double lon,
    int hours = 24,
    String unitsSystem = 'METRIC',
    String languageCode = 'sv-SE',
  }) async {
    final uri = Uri.https(_host, _hoursPath, {
      'key': _apiKey,
      'location.latitude': lat.toString(),
      'location.longitude': lon.toString(),
      'hours': hours.toString(),
      'unitsSystem': unitsSystem,
      'languageCode': languageCode,
    });

    final res = await _client.get(uri, headers: {'x-goog-api-key': _apiKey});

    if (res.statusCode != 200) {
      throw Exception('Weather API fel ${res.statusCode}: ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }
}
