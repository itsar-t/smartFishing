import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/auth_gate.dart';
import 'utils/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

// ⬇️ Lägg till dessa imports så routes pekar rätt
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/learn_fishing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // (Valfritt) App Check – bara om du har "enforce" på Firestore/Functions
  // import 'package:firebase_app_check/firebase_app_check.dart';
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug, // byt till playIntegrity i prod
  //   appleProvider: AppleProvider.debug,     // byt till deviceCheck/appAttest i prod
  // );

  // FMTC init (kartan)
  try {
    await FMTCObjectBoxBackend().initialise();
  } catch (e) {
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEBF0FC),
        ), //.copyWith(primary: const Color(0xFF21005d)),
        useMaterial3: true,
      ),

      // 🚪 Startar via AuthGate (visar rätt sida beroende på inloggning)
      home: const AuthGate(),

      // 🗺️ Namngivna routes som din kod anropar på flera ställen
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
      },

      // 🙏 Fallback om någon försöker navigera till en okänd route
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
