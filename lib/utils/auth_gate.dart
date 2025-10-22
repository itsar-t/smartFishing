import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Lyssnar konstant på ändringar i autentiseringsstatus
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Om vi inte har fått svar än, visa en laddningsindikator
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // Om vi har data (en användare), visa hemsidan
        return const HomePage();
      },
    );
  }
}
