import 'package:flutter/material.dart';
import 'package:smart_fishing/widgets/lure_card.dart';

class LurePage extends StatefulWidget {
  const LurePage({super.key});

  @override
  State<LurePage> createState() => _LurePageState();
}

class _LurePageState extends State<LurePage> {
  final TextEditingController _search = TextEditingController();

  // “Källan” för dina kort. Här kan du lägga till fler ämnen.
  final List<_Lure> _allTopics = const [
    _Lure(title: 'Spoon Lure', image: 'assets/images/spoon.png'),
    _Lure(title: 'Wobbler (Crankbait)', image: 'assets/images/wobbler.png'),
    _Lure(title: 'Spoon Lure', image: 'assets/images/spoon.png'),
    _Lure(title: 'Spoon Lure', image: 'assets/images/spoon.png'),
    _Lure(title: 'Spoon Lure', image: 'assets/images/spoon.png'),
    _Lure(title: 'Spoon Lure', image: 'assets/images/spoon.png'),
    _Lure(title: 'Spoon Lure', image: 'assets/images/spoon.png'),
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
    // Samma sidopadding som du använder kring griden:
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
        title: const Text('Learn about fishing'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔎 Sökfältet under rubriken – precis som i din mock
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search lures…',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧱 Grid med kort – 2 kolumner som i din skiss
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
