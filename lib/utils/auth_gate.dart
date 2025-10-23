import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Ingen user -> visa login
        if (!snap.hasData) return const LoginPage();

        // Vänta in streamen ordentligt
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }

        final user = snap.data!;
        // Gäst? Hoppa direkt vidare (vi skapar inte profil för anonyma)
        if (user.isAnonymous) return const HomePage();

        // Icke-gäst: se till att profil finns innan vi släpper in i appen
        return FutureBuilder<void>(
          future: _ensureUserProfile(user),
          builder: (context, profSnap) {
            if (profSnap.connectionState == ConnectionState.waiting) {
              return const _Splash();
            }
            if (profSnap.hasError) {
              // Något är riktigt fel (oftast rules/permission) -> logga ut
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            }
            return const HomePage();
          },
        );
      },
    );
  }

  // Skapar ett minimalt /users/{uid} om det saknas, och sätter displayName om tomt.
  static Future<void> _ensureUserProfile(User user) async {
    final fs = FirebaseFirestore.instance;
    final docRef = fs.collection('users').doc(user.uid);
    final doc = await docRef.get();

    // Beräkna ett stabilt username
    String computedUsername;
    final dn = (user.displayName ?? '').trim();
    if (dn.isNotEmpty) {
      computedUsername = dn;
    } else if ((user.email ?? '').isNotEmpty) {
      computedUsername = user.email!.split('@').first;
    } else {
      computedUsername = 'user${user.uid.substring(0, 6)}';
    }

    // Skriv profil om den saknas
    if (!doc.exists) {
      await docRef.set({
        'username': computedUsername.toLowerCase(),
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Sätt displayName om tomt (så att UI kan använda det direkt)
    if (dn.isEmpty) {
      await user.updateDisplayName(computedUsername);
    }
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
