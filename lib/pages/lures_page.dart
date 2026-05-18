import 'package:flutter/material.dart';
import 'package:smart_fishing/widgets/lure_card.dart';

class LurePage extends StatefulWidget {
  const LurePage({super.key});

  @override
  State<LurePage> createState() => _LurePageState();
}

class _LurePageState extends State<LurePage> {
  final TextEditingController _search = TextEditingController();

  final List<_Lure> _allTopics = const [
    _Lure(title: 'Spoon Lures', image: 'assets/images/spoon_lure.png'),
    _Lure(title: 'Wobblers (Crankbait)', image: 'assets/images/wobbler.png'),
    _Lure(title: 'Spinners', image: 'assets/images/spinner.png'),
    _Lure(title: 'Pirk Lures', image: 'assets/images/prik_lures.png'),
    _Lure(title: 'Jigs & Softbaits', image: 'assets/images/jigs.png'),
    _Lure(title: 'Bombarda Float', image: 'assets/images/bombarda_float.png'),
    _Lure(title: 'Sabiki Fishing', image: 'assets/images/sabiki_fishing.png'),
  ];

  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    // Samma sidopadding som används i gridden
    const horizontalPadding = 12.0;
    // Spacing mellan kolumnerna:
    const crossSpacing = 12.0;
    // Antal kolumner:
    const columns = 2;

    // Den effektiva bredden som griden har att jobba med
    final gridWidth = screenWidth - (horizontalPadding * 2) - crossSpacing;
    // Bredd per kort:
    final cardWidth = gridWidth / columns;

    // Nederdelens höjd (matcha det du sätter i kortet)
    const bottomHeight = 88.0;

    // Kvadratisk topp => topHeight = cardWidth
    final cardHeight = cardWidth + bottomHeight;

    // childAspectRatio = width / height
    final ratio = cardWidth / cardHeight;

    // Filtrera på sök
    final topics = _allTopics
        .where((t) => t.title.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lures'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              "assets/images/all_baits.png",
              fit: BoxFit
                  .fitWidth, // skalar tills bredden fylls, behåller proportioner
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "There are many different types of lures, each with its own movement and purpose. The most common types are listed below.",
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 🧱 Grid med kort
          // 🔽 Scrollbar yta: under sökfältet, ovanför bottombar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: GridView.builder(
                // gör själva griden scrollbar
                physics:
                    const BouncingScrollPhysics(), // eller ClampingScrollPhysics på Android-stuk
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: topics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: ratio, // 👈 dynamiskt uträknad
                ),

                itemBuilder: (context, i) {
                  final t = topics[i];
                  return LureCard(
                    imagePath: t.image,
                    title: t.title,

                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Open: ${t.title}')),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lure {
  final String title;

  final String image; // ← ny
  const _Lure({required this.title, required this.image});
}
