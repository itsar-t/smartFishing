import 'package:cloud_firestore/cloud_firestore.dart'; // Importera Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'widgets/account_avatar_menu.dart';
import 'widgets/bottom_bar.dart';
import 'pages/add_post_page.dart';
import 'pages/marine_map_page.dart';
import 'pages/feed_page.dart';
import 'widgets/forecast_widget.dart';

// Gör om till en StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username; // En variabel för att lagra användarnamnet
  int _index = 0;

  final _pages = const [
    FeedPage(),
    MarineMapPage(),
    SizedBox.shrink(),
    ForecastWidget(
      lat: 57.5818, // Stora Amundön
      lon: 11.9146,
      placeName: 'Stora Amundön',
      days: 5,
    ),
    Center(child: Text('Tutorial')),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Anropa funktionen som hämtar data när sidan startar
  }

  // En ny funktion för att hämta data från Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Hämta dokumentet från Firestore som matchar den inloggade användarens ID
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Om dokumentet finns, hämta användarnamnet
      if (docSnapshot.exists) {
        setState(() {
          _username = docSnapshot.data()?['username'];
        });
      }
    }
  }

  // Logik för utloggning
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartFishing"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          if (_username != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AccountAvatarMenu(
                username: _username,
                onSignOut: _signOut,
                onOpenProfile: () {
                  // TODO: Navigator.push(... ProfilePage());
                },
              ),
            ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),

      // 💙 Här är vår nya komponent
      bottomNavigationBar: BottomBar(
        currentIndex: _index,
        onTap: (i) {
          // Om användaren trycker på "Add" (flik index 2)
          if (i == 2) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AddPostPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            );

            return; // 👈 Stoppar setState – vi stannar kvar på samma flik
          }

          // Annars byt flik som vanligt
          setState(() => _index = i);
        },
        items: const [
          BottomBarItem(icon: Icons.group, label: 'Records'),
          BottomBarItem(icon: Icons.place, label: 'Map'),
          BottomBarItem(icon: Icons.add, label: 'Add'),
          BottomBarItem(icon: Icons.wb_sunny, label: 'Forecast'),
          BottomBarItem(icon: Icons.menu_book, label: 'Tutorial'),
        ],
      ),
    );
  }
}
