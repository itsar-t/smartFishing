// marine_map_page.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_fishing/utils/weather_service.dart';
import 'package:smart_fishing/utils/wms_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_fishing/widgets/fish_info_card.dart';

class _FishInfo {
  final String title, subtitle, description;
  final String? imageAsset;
  const _FishInfo(this.title, this.subtitle, this.description, this.imageAsset);
}

class MarineMapPage extends StatefulWidget {
  const MarineMapPage({super.key});

  @override
  State<MarineMapPage> createState() => _MarineMapPageState();
}

class _MarineMapPageState extends State<MarineMapPage>
    with SingleTickerProviderStateMixin {
  // --- Controllers/Services ---
  final MapController _map = MapController();
  final _weather = GoogleWeatherService();
  late final AnimationController _compassController;

  // --- UI/State ---

  //Used for initial spawn of map

  LatLng _center = const LatLng(57.58922010406103, 11.903982047912235);

  final List<LatLng> fishMarkers = [
    const LatLng(57.58965834150336, 11.905588374577496),
    const LatLng(57.58743552855953, 11.907009216151488),
  ];

  final List<LatLng> suggestedFishingSpots = [
    const LatLng(57.587653688374466, 11.905524122990151),
    const LatLng(57.589749749351036, 11.904368953523138),
  ];
  final _fishColor = Color(0xFF6B4AD6); // normal purple
  final _fishSelected = Color.fromARGB(
    255,
    151,
    128,
    255,
  ); // lighter purple for "selected"

  // --- UI/State ---
  bool _cardOpen = false;
  static const double _cardHeight = 300; // höjd på kortet (justera)
  _FishInfo? _currentFish; // data som FishInfoCard visar

  _FishInfo _infoForPoint(LatLng p) {
    final k0 = _ptKey(fishMarkers[0]);
    final k1 = _ptKey(fishMarkers[1]);
    final k = _ptKey(p);

    if (k == k0) {
      return const _FishInfo('Mackerel', 'Very good chance', '''
🐟 Behavior: 
Mackerel move in schools near the surface hunting small fish. Watch for diving seabirds – that’s usually where they are!

⚙️ Gear & Setup: 
Spinning rod (8–10 ft) with 0.25–0.35 mm line or 10–15 lb braid.
Mackerel rig (makrillhäckla) or metal lures (20–60 g spoons or jigs).
Reel in fast or with short jerks – they love speed!

⏰ Best time: 
Early morning or evening when the sea is calm. Cloudy days can be great too.

🪣 Keep your catch fresh: 
Bleed and clean immediately, then store on ice. Mackerel spoils quickly.

⚖️ Rules: No license needed for coastal fishing in Sweden, but respect local restrictions and only keep what you’ll use.

💡 Extra tips: 
Polarized sunglasses help spot fish.
Follow the birds or other anglers – mackerel often move in groups.
Try moving 50–100 m if the bite stops.

🔥 Fresh mackerel is amazing grilled, smoked, or fried – enjoy your catch!
''', 'assets/images/mackerel.png');
    } else if (k == k1) {
      return const _FishInfo('Needlefish', 'Good chance', '''
🐟 Behavior:
Needlefish are long, slender surface hunters that love clear and calm waters. They often gather near rocks, piers, and shallow bays chasing small baitfish. You can spot them by their quick, silver flashes near the surface.

⚙️ Gear & Setup:
Light spinning rod (7–9 ft) with 0.20–0.30 mm line or 8–12 lb braid.
Use small spoons, surface lures, or slender softbaits.
Retrieve quickly and steadily — needlefish strike fast when they see movement.

⏰ Best time:
Sunny days and calm seas are perfect. They feed most actively during late morning and evening when baitfish come closer to the surface.

🪣 Keep your catch fresh:
Needlefish have delicate flesh. Bleed immediately and keep on ice or in cold seawater if you plan to eat them.

⚖️ Rules:
No license needed for coastal fishing in Sweden, but always respect local restrictions and only keep what you’ll use.

💡 Extra tips:
Use long pliers when unhooking — their beaks are sharp!
They often jump when hooked, so keep tension on the line.
Try smaller lures if they just “nip” the bait — they can be picky.

🔥 Cooking:
Needlefish have firm, white meat and are delicious grilled or pan-fried. Remove the green-tinted bones before serving — they’re natural and harmless, but look unusual!
''', 'assets/images/needlefish.png');
    }
    return const _FishInfo('Fish', 'Chance unknown', 'No description', null);
  }

  // Depth overlay comes from a public demo WMS (used for examples).
  // The demo WMS server may embed a promotional QR watermark into tiles.
  bool _showDepth = true;
  bool _loadingLocation = false;
  double? _gpsAccuracy;
  LatLng? _userPos;
  double _mapRotation = 0.0;

  // vilka fiskmarkörer som visar "grupp" (true) vs "single" (false)
  // Which fish (by coordinate key) is currently selected. Null = none selected.
  String? _selectedFishKey;

  // Stable key for a LatLng
  String _ptKey(LatLng p) =>
      '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';

  // --- Wind handling ---
  Future<_WindData?>? _windFuture; // endast uppdatera när center ändras "klart"
  final Map<String, _WindData> _windCache =
      {}; // enkel cache för närliggande punkter
  Timer? _windDebounce;

  @override
  void initState() {
    super.initState();
    _compassController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // initial hämtning
    _scheduleWindFetch(_center);
  }

  @override
  void dispose() {
    _windDebounce?.cancel();
    _compassController.dispose();
    super.dispose();
  }

  // Nyckel för enkel spatial cache (avrunda ~300 m)
  String _keyFor(LatLng p) =>
      '${(p.latitude * 1000).round()}_${(p.longitude * 1000).round()}';

  void _scheduleWindFetch(LatLng target) {
    _windDebounce?.cancel();
    _windDebounce = Timer(const Duration(milliseconds: 350), () {
      final key = _keyFor(target);
      if (_windCache.containsKey(key)) {
        final future = Future<_WindData?>.value(_windCache[key]);
        setState(() {
          _windFuture = future;
        });
      } else {
        final future = _fetchWind(target);
        setState(() {
          _windFuture = future;
        });
      }
    });
  }

  // Mer robust vind-parsning – matchar din fungerande ForecastWidget
  Future<_WindData?> _fetchWind(LatLng point) async {
    try {
      final json = await _weather.getDailyForecast(
        lat: point.latitude,
        lon: point.longitude,
        days: 1,
        unitsSystem: 'METRIC',
        languageCode: 'sv-SE',
      );

      // ---- Hjälpare ----
      num? _num(dynamic v) =>
          v is num ? v : (v is String ? num.tryParse(v) : null);

      double? _speedMsFrom(Map<String, dynamic>? speed, {String? keyHint}) {
        if (speed == null) return null;

        final mps = _num(speed['metersPerSecond']) ?? _num(speed['mps']);
        if (mps != null) return mps.toDouble();

        final kph =
            _num(speed['kilometersPerHour']) ??
            _num(speed['kmh']) ??
            _num(speed['kph']);
        if (kph != null) return (kph / 3.6).toDouble();

        final mph = _num(speed['milesPerHour']) ?? _num(speed['mph']);
        if (mph != null) return (mph * 0.44704).toDouble();

        final value = _num(speed['value']);
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
          if (unitStr.contains('mph')) return (value * 0.44704).toDouble();
        }

        if (value != null && unitStr == null) {
          final hint = (keyHint ?? '').toLowerCase();
          final looksKph =
              hint.contains('kph') ||
              hint.contains('kmh') ||
              hint.contains('kilometersperhour') ||
              hint.contains('kilometers_per_hour');
          if (looksKph) return (value / 3.6).toDouble();
        }
        return null;
      }

      double? _degFrom(
        Map<String, dynamic>? wind, [
        Map<String, dynamic>? dir,
      ]) {
        dir ??= wind?['direction'] as Map<String, dynamic>?;
        num? deg =
            _num(dir?['degrees']) ??
            _num(dir?['degree']) ??
            _num(wind?['directionDegrees']) ??
            _num(wind?['deg']) ??
            _num(wind?['windDirectionDegrees']);
        deg ??= (() {
          final v = _num(dir?['value']);
          final u = dir?['unit']?.toString().toLowerCase();
          if (v != null && (u?.contains('deg') ?? false)) return v;
          return null;
        })();
        return deg?.toDouble();
      }

      double? _msFromHour(Map<String, dynamic> h) {
        final wind = h['wind'] as Map<String, dynamic>?;
        final ms =
            _speedMsFrom(
              wind?['speed'] as Map<String, dynamic>?,
              keyHint: 'wind.speed',
            ) ??
            _speedMsFrom(
              h['windSpeed'] as Map<String, dynamic>?,
              keyHint: 'windSpeed',
            ) ??
            _num(h['windSpeedMetersPerSecond'])?.toDouble() ??
            (() {
              final kph = _num(h['windSpeedKilometersPerHour']);
              return kph != null ? (kph / 3.6).toDouble() : null;
            })();
        return ms;
      }

      double? _msFromDay(Map<String, dynamic> d) {
        final daytime = d['daytimeForecast'] as Map<String, dynamic>?;
        final wind =
            (daytime?['wind'] as Map<String, dynamic>?) ??
            (d['wind'] as Map<String, dynamic>?);

        final ms =
            _speedMsFrom(
              wind?['speed'] as Map<String, dynamic>?,
              keyHint: 'wind.speed',
            ) ??
            _speedMsFrom(
              d['windSpeed'] as Map<String, dynamic>?,
              keyHint: 'windSpeed',
            ) ??
            _speedMsFrom(
              d['maxWindSpeed'] as Map<String, dynamic>?,
              keyHint: 'maxWindSpeed',
            ) ??
            _num(d['windSpeedMetersPerSecond'])?.toDouble() ??
            _num(daytime?['windSpeedMetersPerSecond'])?.toDouble() ??
            (() {
              final kph =
                  _num(d['windSpeedKilometersPerHour']) ??
                  _num(daytime?['windSpeedKilometersPerHour']);
              return kph != null ? (kph / 3.6).toDouble() : null;
            })() ??
            (() {
              final sp = wind?['speed'] as Map<String, dynamic>?;
              final raw = _num(sp?['value']);
              return raw != null
                  ? (raw / 3.6).toDouble()
                  : null; // sista utvägen
            })();
        return ms;
      }

      double? _degFromHour(Map<String, dynamic> h) {
        final wind = h['wind'] as Map<String, dynamic>?;
        return _degFrom(wind);
      }

      double? _degFromDay(Map<String, dynamic> d) {
        final daytime = d['daytimeForecast'] as Map<String, dynamic>?;
        final wind =
            (daytime?['wind'] as Map<String, dynamic>?) ??
            (d['wind'] as Map<String, dynamic>?);
        return _degFrom(wind);
      }

      // ---- 1) Försök med närmaste forecast hour ----
      final List hoursRaw = (json['forecastHours'] as List?) ?? const [];
      Map<String, dynamic>? chosenHour;
      if (hoursRaw.isNotEmpty) {
        DateTime? _parseTs(Map h) {
          String? s =
              (h['dateTime'] ?? h['startTime'] ?? h['time'] ?? h['validTime'])
                  ?.toString();
          if (s == null) return null;
          try {
            return DateTime.parse(s).toUtc();
          } catch (_) {
            return null;
          }
        }

        final now = DateTime.now().toUtc();
        Duration bestDiff = const Duration(days: 9999);
        for (final e in hoursRaw) {
          if (e is! Map) continue;
          final m = e.cast<String, dynamic>();
          final ts = _parseTs(m);
          if (ts == null) continue;
          final diff = (ts.difference(now)).abs();
          if (diff < bestDiff) {
            bestDiff = diff;
            chosenHour = m;
          }
        }
        // Om vi inte lyckades parsa tider, ta första
        chosenHour ??= hoursRaw.first is Map
            ? (hoursRaw.first as Map).cast<String, dynamic>()
            : null;
      }

      double? ms;
      double? degFrom;

      if (chosenHour != null) {
        ms = _msFromHour(chosenHour);
        degFrom = _degFromHour(chosenHour);
      }

      // ---- 2) Fallback: dagsprognos ----
      if (ms == null || degFrom == null) {
        final List days = (json['forecastDays'] as List?) ?? const [];
        if (days.isNotEmpty) {
          final d = (days.first as Map).cast<String, dynamic>();
          ms ??= _msFromDay(d);
          degFrom ??= _degFromDay(d);
        }
      }

      if (ms == null || degFrom == null) return null;

      // Konvertera FROM -> TO för pilen (0 = N/upp)
      final degTo = (degFrom + 180.0) % 360.0;

      final out = _WindData(speedMs: ms, directionDegTo: degTo);
      _windCache[_keyFor(point)] = out;
      return out;
    } catch (_) {
      return null;
    }
  }

  // --- UI Actions ---
  Future<void> _goToCurrentLocation() async {
    if (_loadingLocation) return;
    setState(() => _loadingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Platsåtkomst nekad')));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      final here = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _gpsAccuracy = pos.accuracy;
        _center = here;
        _userPos = here;
      });
      _map.move(here, _map.camera.zoom);
      _scheduleWindFetch(here);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kunde inte hitta din plats: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _animateCompassToNorth() {
    try {
      final start = _map.camera.rotation;
      final anim = Tween<double>(begin: start, end: 0.0).animate(
        CurvedAnimation(parent: _compassController, curve: Curves.easeOut),
      );
      void tick() {
        try {
          _map.rotate(anim.value);
        } catch (_) {}
      }

      anim.addListener(tick);
      _compassController
          .forward(from: 0)
          .whenComplete(() => anim.removeListener(tick));
    } catch (_) {
      try {
        _map.rotate(0);
      } catch (_) {
        _map.move(_center, _map.camera.zoom);
      }
    }
  }

  void _openFishInfoFor(LatLng p) {
    setState(() {
      _selectedFishKey = _ptKey(p);
      _currentFish = _infoForPoint(p);
      _cardOpen = true; // öppna panelen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPadding(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: _cardOpen ? _cardHeight : 0),
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 15,
                maxZoom: 19,
                minZoom: 5,
                onMapEvent: (e) {
                  // Uppdatera center kontinuerligt
                  if (e is MapEventMove || e is MapEventRotate) {
                    setState(() {
                      _center = _map.camera.center;
                      _mapRotation = _map.camera.rotation;
                    });
                  }
                  // När användaren "slutar" – trigga vindhämtning (debounce)
                  if (e is MapEventMoveEnd ||
                      e is MapEventFlingAnimationEnd ||
                      e is MapEventDoubleTapZoomEnd) {
                    _scheduleWindFetch(_map.camera.center);
                  }
                },
                onTap: (tapPos, latLng) {
                  // Tap anywhere on the map background -> clear selection
                  if (_selectedFishKey != null) {
                    setState(() {
                      _selectedFishKey = null; // avmarkera ev. marker
                      _currentFish =
                          null; // rensa innehållet i kortet (valfritt)
                      _cardOpen = false; // 🔒 stäng kortet
                    });
                  }
                },
              ),
              children: [
                // 1) Bas - MapTiler Satellite
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/tiles/satellite/{z}/{x}/{y}.jpg?key=ReTRE6bb9rBMk3GASouP',
                  userAgentPackageName: 'com.smartfishing.app',
                  tileProvider: NetworkTileProvider(),
                ),

                // Djupkonturer (WMS overlay). We use a small WMS tile provider that
                // converts z/x/y -> BBOX (EPSG:3857) and calls a WMS GetMap request.
                // Example public WMS server (read-only demo): ows.terrestris.de
                if (_showDepth)
                  TileLayer(
                    // urlTemplate is unused by WmsTileProvider, but flutter_map
                    // expects a template string; set to an empty string.
                    urlTemplate: '',
                    userAgentPackageName: 'com.smartfishing.app',
                    tileProvider: WmsTileProvider(
                      baseUrl: 'https://ows.terrestris.de/osm/service?',
                      layers: 'OSM-WMS',
                      version: '1.3.0',
                      format: 'image/png',
                      transparent: true,
                      crs: 'EPSG:3857',
                      tileSize: 256,
                    ),
                  ),

                // 3) Egna markörer (exempel)
                MarkerLayer(
                  markers: [
                    // --- klickbara fiskmarkörer ---
                    // Colors
                    ...fishMarkers.map((p) {
                      final key = _ptKey(p);
                      final isSelected = (key == _selectedFishKey);

                      return Marker(
                        point: p,
                        width: 42,
                        height: 42,
                        child: GestureDetector(
                          behavior: HitTestBehavior
                              .translucent, // tap without blocking drag too much
                          onTap: () {
                            setState(() {
                              // Tap a fish: select it. If you tap the same again, toggle back (optional).
                              _selectedFishKey = isSelected ? null : key;
                            });
                            // info panel/bottom sheet
                            if (!isSelected) _openFishInfoFor(p);
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: SvgPicture.asset(
                              isSelected
                                  ? 'assets/icons/fish_single.svg'
                                  : 'assets/icons/fish_group.svg',
                              key: ValueKey(isSelected),
                              colorFilter: ColorFilter.mode(
                                isSelected ? _fishSelected : _fishColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    Marker(
                      point: suggestedFishingSpots[0],
                      child: Icon(
                        size: 30,
                        Icons.location_pin,
                        color: const Color.fromARGB(255, 204, 124, 27),
                      ),
                    ),

                    Marker(
                      point: suggestedFishingSpots[1],
                      child: Icon(
                        size: 30,
                        Icons.location_pin,
                        color: const Color.fromARGB(255, 223, 10, 10),
                      ),
                    ),

                    //----------- fake location marker to prototype ------
                    Marker(
                      point: const LatLng(
                        57.58904456033999,
                        11.902849366307418,
                      ),
                      width: 12,
                      height: 12,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueGrey, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.25 * 255).round(),
                              ),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //----------- correct location marker -------
                    if (_userPos != null)
                      Marker(
                        point: _userPos!,
                        width: 12,
                        height: 12,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.25 * 255).round(),
                                ),
                                blurRadius: 6,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // --- Vind: marker + overlay ---
                FutureBuilder<_WindData?>(
                  future: _windFuture,
                  builder: (context, snap) {
                    final wind = snap.data;

                    // Fallbacks om inget finns ännu
                    final double speed = wind?.speedMs ?? 0;
                    final double dirTo = wind?.directionDegTo ?? 0;

                    return Positioned(
                      left: 12,
                      top: 12 + MediaQuery.of(context).padding.top,
                      child: _WindBadge(
                        speedMs: speed,
                        dirToDegrees: dirTo,
                        mapRotation: _mapRotation,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // --- Zoom-knappar ---
          Positioned(
            right: 12,
            bottom: 140,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    final z = _map.camera.zoom;
                    _map.move(_center, (z + 1).clamp(0.0, 19.0));
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    final z = _map.camera.zoom;
                    _map.move(_center, (z - 1).clamp(0.0, 19.0));
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          //--- Location Button ---
          Positioned(
            right: 12,
            top: 180,
            child: FloatingActionButton(
              heroTag: 'current position',
              mini: true,
              onPressed: _loadingLocation ? null : _goToCurrentLocation,

              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // --- Lagerknapp ---
          Positioned(
            right: 12,
            top: 120,
            child: FloatingActionButton(
              heroTag: 'layers',
              mini: true,
              onPressed: () => setState(() => _showDepth = !_showDepth),
              backgroundColor: Colors.blue.shade700,
              child: Icon(
                _showDepth ? Icons.layers_clear : Icons.layers,
                color: Colors.white,
              ),
            ),
          ),

          // --- Kompass (modern stil) ---
          Positioned(
            right: 12,
            top: 60,
            child: _CompassButton(
              rotationDegrees: _mapRotation,
              onReset: _animateCompassToNorth,
            ),
          ),

          // --- Weak GPS varning ---
          if (_gpsAccuracy != null && _gpsAccuracy! > 25)
            Positioned(
              right: 12,
              bottom: 220,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.15 * 255).round()),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  'WEAK\nGPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // --- Fish info panel ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: _cardOpen ? 0 : -(_cardHeight + 100),
            child: IgnorePointer(
              ignoring: !_cardOpen,
              child: SizedBox(
                height: _cardHeight,
                width: double.infinity,
                child: _currentFish == null
                    ? const SizedBox.shrink()
                    : FishInfoCard(
                        title: _currentFish!.title,
                        subtitle: _currentFish!.subtitle,
                        description: _currentFish!.description,
                        imageAsset: _currentFish!.imageAsset,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindData {
  final double speedMs;
  final double directionDegTo; // dit vinden blåser (0 = N/upp)
  const _WindData({required this.speedMs, required this.directionDegTo});
}

class _WindBadge extends StatelessWidget {
  final double speedMs;
  final double dirToDegrees; // dit vinden blåser (0 = N/upp)
  final double mapRotation; // kartans rotation i grader

  const _WindBadge({
    required this.speedMs,
    required this.dirToDegrees,
    required this.mapRotation,
  });

  // Enkel färglogik: <4 m/s = grön, 4–7.9 = orange, >=8 = röd
  Color _mainColor() {
    if (speedMs < 4) return Colors.green.shade700;
    if (speedMs < 8) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final c = _mainColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pilens vinkel justeras med kartans rotation
          Transform.rotate(
            angle:
                (dirToDegrees + mapRotation) *
                math.pi /
                180.0, // relativ mot kartan
            child: Icon(Icons.arrow_upward, size: 20, color: c),
          ),
          const SizedBox(width: 10),
          Text(
            'Vind ${speedMs.toStringAsFixed(0)} m/s',
            style: TextStyle(fontWeight: FontWeight.w700, color: c),
          ),
        ],
      ),
    );
  }
}

class _CompassButton extends StatelessWidget {
  final double rotationDegrees;
  final VoidCallback onReset;
  const _CompassButton({required this.rotationDegrees, required this.onReset});

  @override
  Widget build(BuildContext context) {
    // färger
    final bg = Colors.blueGrey.shade900;
    final red = Colors.red.shade600;

    return GestureDetector(
      onTap: onReset,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Vit "N"
            const Text(
              "N",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            // Röd triangel (roteras motsatt mot kartrotation)
            Transform.rotate(
              angle: (-rotationDegrees) * math.pi / 180.0,
              alignment: Alignment.center,
              child: Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.change_history, // liten triangel
                  size: 14,
                  color: red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FishIconToggle extends StatefulWidget {
  const FishIconToggle({super.key});

  @override
  State<FishIconToggle> createState() => _FishIconToggleState();
}

class _FishIconToggleState extends State<FishIconToggle> {
  bool _isGroup = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isGroup = !_isGroup;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: SvgPicture.asset(
          _isGroup ? 'assets/icons/fish_group.svg' : 'assets/icons/fish_.svg',
          key: ValueKey(_isGroup),
          width: 42,
          height: 42,
          colorFilter: const ColorFilter.mode(
            Color(0xFF6B4AD6),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
