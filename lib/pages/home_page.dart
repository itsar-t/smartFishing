import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/account_avatar_menu.dart';
import '../widgets/bottom_bar.dart';
import 'add_post_page.dart';
import 'marine_map_page.dart';
import 'feed_page.dart';
import '../widgets/forecast_widget.dart';
import '../pages/learn_fishing_page.dart';
import 'licence_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username; // hämtas från Firestore för icke-gäster
  int _index = 0;
  final _auth = FirebaseAuth.instance;
  late final Stream<User?> _authStream;

  final _pages = const [
    FeedPage(),
    MarineMapPage(),
    LicencePage(),
    ForecastWidget(
      lat: 57.5818,
      lon: 11.9146,
      placeName: 'Stora Amundön',
      days: 5,
    ),
    LearnFishingPage(), // 👈 ersätter Center(child: Text('Tutorial')),
  ];

  @override
  void initState() {
    super.initState();
    _authStream = _auth.authStateChanges();
    _checkForCorruptUser();
  }

  // Om profil-läsning brakar (t.ex. p.g.a. regler eller saknat doc) -> logga ut
  Future<void> _checkForCorruptUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } catch (e) {
      debugPrint('⚠️ User record missing, forcing sign-out: $e');
      await _auth.signOut();
    }
  }

  // Ladda username från Firestore endast för icke-gäst
  Future<void> _loadUsername(User u) async {
    if (u.isAnonymous) {
      if (mounted) setState(() => _username = null);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .get();
    if (!mounted) return;
    setState(() => _username = (doc.data()?['username'] as String?)?.trim());
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isGuest = (user?.isAnonymous ?? false);

        // Hämta username när vi får en icke-gäst user från streamen
        if (user != null && !user.isAnonymous) {
          _loadUsername(user);
        }

        final displayName = isGuest
            ? 'Guest'
            : (_username ??
                  (user?.displayName?.trim()).nullableNonEmpty ??
                  (user?.email?.split('@').first ?? 'Unknown'));
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text("SmartFishing"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            actions: [
              // Visa + bara för icke-gäst
              if (!isGuest && _index == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const AddPostPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, color: cs.onPrimary),
                    label: Text(
                      'Add post',
                      style: TextStyle(color: cs.onPrimary),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size(0, 48), // gör knappen lagom hög
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AccountAvatarMenu(
                    username: displayName, // alltid en icke-null String
                    isGuest: isGuest,
                    onSignOut: _signOut,
                    onOpenProfile: () {
                      if (isGuest) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Guest mode – skapa konto för profil.',
                            ),
                          ),
                        );
                        return;
                      }
                      // TODO: Navigator.push(... ProfilePage());
                    },
                    onUpgrade: isGuest
                        ? () => Navigator.pushNamed(context, '/register')
                        : null,
                  ),
                ),
            ],
          ),

          // ===== BODY =====
          body: Column(
            children: [
              // 👇 Guest Mode-banner (visas bara när isGuest == true)
              if (isGuest)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(.25),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Guest mode – Upgrade account to be able to make posts.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text('Uppgradera'),
                      ),
                    ],
                  ),
                ),

              // Din riktiga sida
              Expanded(
                child: IndexedStack(index: _index, children: _pages),
              ),
            ],
          ),

          bottomNavigationBar: BottomBar(
            currentIndex: _index,
            onTap: (i) {
              setState(() => _index = i);
            },
            items: const [
              BottomBarItem(icon: Icons.group, label: 'Records'),
              BottomBarItem(icon: Icons.place, label: 'Map'),
              BottomBarItem(icon: Icons.add_shopping_cart, label: 'License'),
              BottomBarItem(icon: Icons.wb_sunny, label: 'Forecast'),
              BottomBarItem(icon: Icons.menu_book, label: 'Learn'),
            ],
          ),
        );
      },
    );
  }
}

// Liten hjälpare så vi slipper null/empty-krångel
extension on String? {
  String? get nullableNonEmpty {
    final s = this?.trim();
    return (s == null || s.isEmpty) ? null : s;
  }
}
