import 'package:flutter/material.dart';
import '../widgets/fish_card.dart';
// Not used, this is for feature work

class FishesPage extends StatelessWidget {
  const FishesPage({super.key});

  static const _fishes = <({String name, String asset})>[
    (name: 'Perch', asset: 'assets/images/fish/perch.png'),
    (name: 'Pike', asset: 'assets/images/fish/pike.png'),
    (name: 'Zander', asset: 'assets/images/fish/zander.png'),
    (name: 'Rainbow trout', asset: 'assets/images/fish/rainbow_trout.png'),
    (name: 'Brown trout', asset: 'assets/images/fish/brown_trout.png'),
    (name: 'Grayling', asset: 'assets/images/fish/grayling.png'),
    (name: 'Char', asset: 'assets/images/fish/char.png'),
    (name: 'Common bream', asset: 'assets/images/fish/common_bream.png'),
    // …lägg till fler här
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish species'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsivt antal kolumner
          final width = constraints.maxWidth;
          int columns = 2;
          if (width >= 600) columns = 3;
          if (width >= 900) columns = 4;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: _fishes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4, // bild + namn
            ),
            itemBuilder: (context, i) {
              final f = _fishes[i];
              return Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: FishCard(
                  name: f.name,
                  asset: f.asset,
                  onTap: () {
                    // Valfritt: öppna en GuideDetailPage med mer info
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (_) => GuideDetailPage(
                    //     title: f.name,
                    //     headerImage: f.asset,
                    //     blocks: const [
                    //       GuideBlock.section(
                    //         heading: 'About',
                    //         text: 'Habitat, size, season…',
                    //       )
                    //     ],
                    //   ),
                    // ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
