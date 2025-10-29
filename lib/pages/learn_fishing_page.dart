import 'package:flutter/material.dart';
import '../widgets/learn_topic_card.dart';
import '../pages/guide_detail_page.dart';
import '../widgets/guide_blocks.dart';
import '../pages/lures_page.dart';

class LearnFishingPage extends StatefulWidget {
  const LearnFishingPage({super.key});

  @override
  State<LearnFishingPage> createState() => _LearnFishingPageState();
}

class _LearnFishingPageState extends State<LearnFishingPage> {
  final TextEditingController _search = TextEditingController();

  // “Källan” för dina kort. Här kan du lägga till fler ämnen.
  final List<_Topic> _allTopics = const [
    _Topic(
      title: 'Conditions',
      subtitle: 'Temperature & weather …',
      image: 'assets/images/conditions.png',
    ),
    _Topic(
      title: 'Tides',
      subtitle: 'Waves & arrow',
      image: 'assets/images/tides_card.png',
    ),
    _Topic(
      title: 'Gear',
      subtitle: 'Rods & Reels',
      image: 'assets/images/gear.png',
    ),
    _Topic(
      title: 'Live baits',
      subtitle: 'Small fishes, shrimps …',
      image: 'assets/images/live_baits.png',
    ),

    _Topic(
      title: 'Lures',
      subtitle: 'All artificial lure types',
      image: 'assets/images/lures.png',
    ),
    _Topic(
      title: 'Float fishing',
      subtitle: 'Basic knots',
      image: 'assets/images/float_fishing.png',
    ),
    _Topic(
      title: 'Stream water',
      subtitle: '(Rivers & Currents)',
      image: 'assets/images/stream_river.png',
    ),
    _Topic(
      title: 'Knots',
      subtitle: 'Basic knots',
      image: 'assets/images/knots.png',
    ),
    _Topic(
      title: 'Fishing ethics',
      subtitle: 'How should we do...',
      image: 'assets/images/ethics_fishing.png',
    ),
    _Topic(
      title: 'Fishing rules',
      subtitle: 'Licenses and more',
      image: 'assets/images/rules.png',
    ),
    _Topic(
      title: 'Fishes',
      subtitle: 'Fish species',
      image: 'assets/images/fishes.png',
    ),
  ];

  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Exempel: Tides
  void openTides(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Tides',
          headerImage: 'assets/images/tides.png', // 16:9 rekommenderas
          blocks: const [
            GuideBlock.section(
              heading: 'What Are Tides?',
              text: '''The sea level rises and falls twice each day.
This happens because the moon and sun pull on the water.
The cycle repeats every 12.5 hours, creating two high tides and two low tides daily.''',
            ),
            GuideBlock.section(
              heading: 'Why Tides Matter for Fishing',
              text:
                  '''When the water rises (flood tide), fish move closer to shore to hunt.
When the water falls (ebb tide), fish go back to deeper areas.
Fish like sea trout are most active during moving water, not at still high or low tide.''',
            ),
            GuideBlock.section(
              heading: 'Best Time to Fish',
              text:
                  '''Start fishing 1–2 hours before high tide and       continue until it begins to fall.
Avoid the still period when the tide changes — fish are less active.
If the wind blows toward the shore, that’s even better — it brings food and fish closer.''',
            ),
            GuideBlock.section(
              heading: 'Local Tide Strength',
              text:
                  '''In Sweden, Denmark, and the Baltic Sea, tides are small (only 20–30 cm).
But wind can change the water level a lot — sometimes more than the tide itself!
''',
            ),
            GuideBlock.section(
              heading: 'Tip For Beginners ',
              text: '''Don’t just watch the clock — watch the water.
Look for signs like:
Stronger current
Rising water line
Active seagulls or small fish jumping''',
            ),
          ],
        ),
      ),
    );
  }

  // Exempel: Stream Water (med mellanbild)
  void openStreamWater(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Stream Water',
          headerImage: 'assets/learn/stream_header.png',
          blocks: const [
            GuideBlock.section(
              heading: 'Fishing in Streams',
              text:
                  'Current moves bait and fish. Salmon and trout often swim upstream to feed or spawn.',
            ),
            GuideBlock.section(
              heading: 'Equipment',
              text:
                  'Use sturdy gear. Spinning reel size 3000–4000 (7000 for heavy), 9–13 ft rod around 20 kg class.',
            ),
            GuideBlock.section(
              heading: 'Baits and Weights',
              text:
                  'Spinners, lures, worms, shrimps. Add a sinker 0.5–2 m before the bait to reach depth.',
            ),
            GuideBlock.image(
              asset: 'assets/learn/stream_mid.png',
              caption: 'Mend line and drift naturally with the current.',
            ),
            GuideBlock.section(
              heading: 'Tips',
              text:
                  'Cast slightly upstream; let the current carry your bait. Match weight to current: faster water needs heavier weights.',
            ),
          ],
        ),
      ),
    );
  }

  void openLures(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LurePage()));
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
        .where(
          (t) =>
              t.title.toLowerCase().contains(_query) ||
              t.subtitle.toLowerCase().contains(_query),
        )
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
                hintText: 'Search topics…',
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
                  return LearnTopicCard(
                    imagePath: t.image,
                    title: t.title,
                    subtitle: t.subtitle,
                    onTap: () {
                      switch (t.title) {
                        case 'Tides':
                          openTides(context);
                          break;
                        case 'Stream Water':
                          openStreamWater(context);
                          break;
                        case 'Lures':
                          openLures(context);
                        default:
                          // Fallback: öppna sida med header = kortbild och en enkel “Coming soon…”
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GuideDetailPage(
                                title: t.title,
                                headerImage: t.image, // återanvänd kortets bild
                                blocks: const [
                                  GuideBlock.section(
                                    heading: 'Coming soon',
                                    text:
                                        'This tutorial is under construction.',
                                  ),
                                ],
                              ),
                            ),
                          );
                      }
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

class _Topic {
  final String title;
  final String subtitle;
  final String image; // ← ny
  const _Topic({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}
