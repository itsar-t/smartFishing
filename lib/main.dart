import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/auth_gate.dart';
import 'utils/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialise the FMTC backend (ObjectBox) before using any FMTC APIs.
  // See: https://fmtc.jaffaketchup.dev/usage/initialisation
  try {
    await FMTCObjectBoxBackend().initialise();
  } catch (e) {
    // If initialisation fails, we still continue but map caching won't be
    // available. The app should continue to run and show tiles via network.
    // Log to console for developer visibility.
    // ignore: avoid_print
    print('FMTC initialisation failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFishing',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 4, 3, 60))
            // Steg 2: Använd .copyWith() för att åsidosätta BARA primärfärgen
            .copyWith(
              primary: const Color(0xFF21005D), // Sätt din exakta färg här
            ),
        useMaterial3: true,
      ),
      // Vi startar med AuthGate!
      home: const AuthGate(),
    );
  }
}
