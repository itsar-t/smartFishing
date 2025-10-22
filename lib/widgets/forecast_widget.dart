import 'package:smart_fishing/utils/weather_service.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
// justera sökväg om din fil ligger annorlunda

class ForecastWidget extends StatefulWidget {
  const ForecastWidget({
    super.key,
    required this.lat,
    required this.lon,
    this.placeName,
    this.days = 5,
  });

  final double lat;
  final double lon;
  final String? placeName;
  final int days;

  @override
  State<ForecastWidget> createState() => _ForecastWidgetState();
}

class _ForecastWidgetState extends State<ForecastWidget> {
  final _api = GoogleWeatherService();
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getDailyForecast(
      lat: widget.lat,
      lon: widget.lon,
      days: widget.days,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.placeName;

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Fel: ${snap.error}'),
          );
        }

        final data = snap.data!;
        final List days = (data['forecastDays'] as List?) ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: days.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final day = days[i] as Map<String, dynamic>;
                  final displayDate =
                      day['displayDate'] as Map<String, dynamic>?;

                  // temperatur
                  final num? maxT = _numOrNull(
                    day['maxTemperature']?['degrees'],
                  );
                  final num? minT = _numOrNull(
                    day['minTemperature']?['degrees'],
                  );

                  // beskrivning & ikon
                  final daytime =
                      day['daytimeForecast'] as Map<String, dynamic>?;
                  final cond =
                      daytime?['weatherCondition'] as Map<String, dynamic>?;
                  final iconBase = cond?['iconBaseUri'] as String?;
                  final desc = (cond?['description']?['text'] as String?) ?? '';

                  // vind
                  final double? ms = _windMs(day); // m/s
                  final double? deg = _windDeg(day); // 0=N (pil upp)

                  String dateStr = '';
                  if (displayDate != null) {
                    dateStr =
                        '${displayDate['year']}-${_two(displayDate['month'])}-${_two(displayDate['day'])}';
                  }

                  // pil som roteras efter grader
                  Widget windArrow = const SizedBox.shrink();
                  if (deg != null) {
                    windArrow = Transform.rotate(
                      angle:
                          (deg + 180) * math.pi / 180.0, // 🔁 vänd 180 grader
                      child: const Icon(Icons.arrow_upward, size: 20),
                    );
                  }

                  return ListTile(
                    // OBS: Google ger ofta SVG i iconBase. Vi försöker .png först;
                    // om den inte finns visas fallback-ikon.
                    leading: iconBase != null
                        ? Image.network(
                            '$iconBase.png',
                            width: 32,
                            height: 32,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.wb_sunny_outlined),
                          )
                        : const Icon(Icons.wb_sunny_outlined),
                    title: Text('$dateStr  $desc'),
                    subtitle: Text(
                      'Max ${maxT?.toStringAsFixed(0) ?? '-'}°  '
                      'Min ${minT?.toStringAsFixed(0) ?? '-'}°\n'
                      'Vind ${ms != null ? ms.toStringAsFixed(0) : '-'} m/s',
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: windArrow,
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ---- Hjälpare ----

  static num? _numOrNull(dynamic v) =>
      v is num ? v : (v is String ? num.tryParse(v) : null);

  static String _two(dynamic n) =>
      n == null ? '--' : n.toString().padLeft(2, '0');

  /// Försök plocka vind i m/s från flera tänkbara fält i Google Weather-svaret.
  // ---- NY, mer robust vind-parsning ----

  double? _windMs(Map<String, dynamic> day) {
    Map<String, dynamic>? daytime =
        day['daytimeForecast'] as Map<String, dynamic>?;
    Map<String, dynamic>? wind =
        (daytime?['wind'] as Map<String, dynamic>?) ??
        (day['wind'] as Map<String, dynamic>?);

    double? fromSpeedMap(Map<String, dynamic>? speed, {String? keyHint}) {
      if (speed == null) return null;

      // 1) Tydliga m/s-fält
      final mps =
          _numOrNull(speed['metersPerSecond']) ?? _numOrNull(speed['mps']);
      if (mps != null) return mps.toDouble();

      // 2) Tydliga km/h-fält
      final kph =
          _numOrNull(speed['kilometersPerHour']) ??
          _numOrNull(speed['kmh']) ??
          _numOrNull(speed['kph']);
      if (kph != null) return (kph / 3.6).toDouble();

      // 3) value + unit/units/unitCode
      final value = _numOrNull(speed['value']);
      final unitStr = (speed['unit'] ?? speed['units'] ?? speed['unitCode'])
          ?.toString()
          .toLowerCase();
      if (value != null && unitStr != null) {
        if (unitStr.contains('m/s') || unitStr.contains('m_s-1')) {
          return value.toDouble();
        }
        if (unitStr.contains('km/h') || unitStr.contains('kph')) {
          return (value / 3.6).toDouble();
        }
        if (unitStr.contains('mph')) {
          return (value * 0.44704).toDouble();
        }
      }

      // 4) Om inget av ovan men nyckeln antyder kph → anta km/h, annars ignorera
      if (value != null && unitStr == null) {
        final hint = (keyHint ?? '').toLowerCase();
        final looksKph =
            hint.contains('kph') ||
            hint.contains('kmh') ||
            hint.contains('kilometersperhour') ||
            hint.contains('kilometers_per_hour');
        if (looksKph) return (value / 3.6).toDouble();
        // okänt utan enhet → returnera null hellre än att gissa m/s
      }

      return null;
    }

    // ---- Packa ut rimliga källor, i prioriteringsordning ----
    double? v;

    // wind.speed
    v = fromSpeedMap(
      wind?['speed'] as Map<String, dynamic>?,
      keyHint: 'wind.speed',
    );
    if (v != null) return v;

    // day.windSpeed / day.maxWindSpeed (Google kan lägga här i km/h)
    v = fromSpeedMap(
      day['windSpeed'] as Map<String, dynamic>?,
      keyHint: 'windSpeed',
    );
    if (v != null) return v;

    v = fromSpeedMap(
      day['maxWindSpeed'] as Map<String, dynamic>?,
      keyHint: 'maxWindSpeed',
    );
    if (v != null) return v;

    // rena m/s-fält
    v = _numOrNull(day['windSpeedMetersPerSecond'])?.toDouble();
    if (v != null) return v;
    v = _numOrNull(daytime?['windSpeedMetersPerSecond'])?.toDouble();
    if (v != null) return v;

    // rena km/h-fält (konvertera)
    final kphDirect =
        _numOrNull(day['windSpeedKilometersPerHour']) ??
        _numOrNull(daytime?['windSpeedKilometersPerHour']);
    if (kphDirect != null) return (kphDirect / 3.6).toDouble();

    // Sista: om speed = {value: X} utan enhet – anta hellre km/h än m/s (vanligare i daglig översikt)
    final speedMap = wind?['speed'] as Map<String, dynamic>?;
    final rawVal = _numOrNull(speedMap?['value']);
    if (rawVal != null) return (rawVal / 3.6).toDouble();

    return null; // hellre null än fel enhet
  }

  // Vindriktning (0 = N). Utökad med fler fallbacks.
  double? _windDeg(Map<String, dynamic> day) {
    Map<String, dynamic>? daytime =
        day['daytimeForecast'] as Map<String, dynamic>?;
    Map<String, dynamic>? wind =
        (daytime?['wind'] as Map<String, dynamic>?) ??
        (day['wind'] as Map<String, dynamic>?);

    Map<String, dynamic>? dir = wind?['direction'] as Map<String, dynamic>?;

    num? deg =
        _numOrNull(dir?['degrees']) ??
        _numOrNull(dir?['degree']) ??
        _numOrNull(wind?['directionDegrees']) ??
        _numOrNull(day['windDirectionDegrees']) ??
        _numOrNull(day['windDeg']) ??
        _numOrNull(daytime?['windDirectionDegrees']);

    // Ibland ligger värdet som "value"+"unit" (grader)
    deg ??= (() {
      final value = _numOrNull(dir?['value']);
      final unit = dir?['unit']?.toString().toLowerCase();
      if (value != null && unit != null && unit.contains('deg')) return value;
      return null;
    })();

    return deg?.toDouble();
  }
}
