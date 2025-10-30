import 'package:flutter/material.dart';
import '../widgets/learn_topic_card.dart';
import '../pages/guide_detail_page.dart';
import '../widgets/guide_blocks.dart';
import '../pages/lures_page.dart';
import '../pages/fish_poster_page.dart';

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
      title: 'Live Baits',
      subtitle: 'Small fishes, shrimps …',
      image: 'assets/images/live_baits.png',
    ),

    _Topic(
      title: 'Lures',
      subtitle: 'All artificial lure types',
      image: 'assets/images/lures.png',
    ),
    _Topic(
      title: 'Float Fishing',
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
      title: 'Fishing Ethics',
      subtitle: 'How should we do...',
      image: 'assets/images/ethics.png',
    ),
    _Topic(
      title: 'Fishing Rules',
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
  void openConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Conditions',
          headerImage: 'assets/images/weather_wave.png',
          blocks: const [
            GuideBlock.section(
              heading: 'Wind',
              text:
                  '''Wind moves surface water and food. When the wind blows toward the shore, it pushes insects and small fish closer to land — and bigger fish follow.
Tip: Fish on the side where the wind blows toward you. A light to moderate breeze is best; strong wind stirs mud and makes fishing harder.''',
            ),
            GuideBlock.section(
              heading: 'Best wind direction',
              text:
                  '''Winds coming from the southwest or west are often good for fishing because they usually bring mild, humid air and comfortable water temperatures.
But the most important thing is where the wind pushes food — fish often gather on the side where the wind hits the shore.''',
            ),
            GuideBlock.section(
              heading: 'Temperature and Pressure',
              text:
                  '''Fish sense weather changes through water pressure. When pressure is steady, they stay active.
A falling pressure (before rain or a storm) can make fish feed for a short time — then they slow down.
Sudden temperature drops or cold fronts often make fish go deeper and rest until conditions stabilize.''',
            ),
            GuideBlock.section(
              heading: 'Clouds and Sunlight',
              text:
                  '''Fish prefer soft or changing light. On cloudy days, they swim higher and feed more.
In bright sunlight, they often hide in deeper or shaded water.
Best times: Early morning, late evening, or during light rain.
''',
            ),
            GuideBlock.section(
              heading: 'Before You Go',
              text:
                  '''Always check wind direction, temperature, and pressure before fishing.
The best mix is a light breeze, steady pressure, and a cloudy sky — that’s when most fish are usually feeding.''',
            ),
          ],
        ),
      ),
    );
  }

  void openTides(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Tides',
          headerImage: 'assets/images/tides.png',
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
But wind can change the water level a lot — sometimes more than the tide itself!''',
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

  void openLiveBaits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Live Baits',
          headerImage: 'assets/images/live_baits_content.png',
          blocks: const [
            GuideBlock.section(
              heading: 'Why use live baits?',
              text:
                  '''In Sweden, many people who fish use natural baits because they smell and taste like real food to fish. Common baits include worms, shrimps, maggots, small white larvae, corn, and sometimes small live fish. Worms are the most popular and work well for species such as perch, trout, and roach. Shrimps are often used in saltwater, especially for sea trout, flatfish, and cod. Maggots and small white larvae are effective for smaller freshwater fish, while corn is a good choice for calm-water species like roach, bream, and carp. Although corn doesn’t move, its bright color and sweet scent attract fish searching for easy food.

For predator fishing, small live fish such as minnows or roach can be used because their movement in the water attracts pike and perch. Always check local fishing rules, as using live fish as bait is not allowed everywhere.

Another very popular option is PowerBait (PowerBall) — a soft, scented dough that looks and smells like natural bait. It’s especially effective for rainbow trout in stocked lakes and is easy to shape and attach to the hook.

Keep all baits cool and out of direct sunlight, and make sure they stay fresh and active. Never throw leftover bait into the water — dispose of it properly on land or save it for next time.''',
            ),
          ],
        ),
      ),
    );
  }

  void openFloatFishing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Float Fishing',
          headerImage: 'assets/images/float_fIshing_setups.png',
          blocks: const [
            GuideBlock.section(
              heading: '',
              text:
                  '''Float fishing, also known as using a bobber, is a simple and effective method where a small buoy is attached to the line to hold the bait at a chosen depth and show when a fish bites. It’s a versatile and beginner-friendly technique that works well in both still water and rivers.

The float acts as a visual signal — when a fish takes the bait, it might sink, lift, or move sideways. By sliding the float up or down the line, you can control how deep the bait is presented. Small weights called split shots help the bait sink and stay steady at the right depth, while a plummet can be used first to measure the water depth.

A basic float fishing setup includes a float, rod, reel, line, hook, and a few accessories like split shots, a plummet, and a landing net. The line strength and hook size depend on the fish species you’re targeting.

When fishing in a river, you can let the current carry the bait downstream; in still water, you control the drift yourself. Successful float fishing depends on watching the float carefully — even small movements can mean a bite — and adjusting the depth until you find where the fish are feeding.
''',
            ),
            GuideBlock.section(
              heading: 'Tips:',
              text: '''Regularly change the bait depth to find active fish.
Keep tension on the line and react quickly when the float moves.
Match the float type to the conditions — stick floats are good for moving water, while slimmer floats work best in calm lakes or ponds.
''',
            ),
          ],
        ),
      ),
    );
  }

  void openStreamWater(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Stream Water',
          headerImage: 'assets/images/stream_water.png',
          blocks: const [
            GuideBlock.section(
              heading: "",
              text:
                  '''Fishing in running water, like rivers or strong streams, is different from still water. The current affects how the bait moves and how fish behave — especially salmon and trout, which often swim upstream to feed or spawn.''',
            ),
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
              asset: 'assets/images/sanke.png',
              caption: 'Mend line and drift naturally with the current',
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

  void openFishingEthics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Fishing Ethics',
          headerImage: 'assets/images/ethics_fishing.png',
          blocks: const [
            GuideBlock.section(
              heading: "Respect the environment and resources",
              text:
                  '''Fishing ethics include respecting the environment and other anglers, following all regulations, handling fish humanely, and practicing responsible catch-and-release techniques. This means not littering, keeping only what you will use, and releasing the rest with care to ensure their survival. It also involves sharing the water courteously, giving others space, and properly disposing of all trash.

Clean up: Leave no trash behind, including fishing line, bait containers, and other litter. You should also clean up trash left by others.
Avoid pollution: Do not dump pollutants like fuel or oil into the water.
Prevent invasive species: Never release live bait fish into a new body of water, as this can introduce harmful species.
Respect habitats: Follow designated trails and parking areas to protect shorelines and other natural areas.
                  ''',
            ),

            GuideBlock.section(
              heading: 'Handle fish humanely',
              text:
                  '''Wet your hands: Always wet your hands or use a net before touching a fish to protect its slime coat.
Minimize air exposure: Handle fish as little and as quickly as possible.
Support properly: Hold fish horizontally to support their weight, especially large fish. Avoid holding them by their gills or eyes.
Use appropriate tools: Have tools like forceps or long-nosed pliers ready for hook removal. If a fish has swallowed a hook, cut the line as close to the hook as possible and release it.
Revive if needed: If a fish doesn't swim away, revive it by moving it gently back and forth in the water to push water through its gills until it swims off on its own.''',
            ),
            GuideBlock.section(
              heading: 'Be a responsible angler',
              text:
                  '''Follow the law: Understand and follow all local fishing and boating regulations, including size and catch limits.
Keep only what you will use: Only harvest the fish you plan to eat and properly dispose of the rest.
Practice catch-and-release: When releasing fish, do so carefully and efficiently.
Educate others: Share best practices and teach others about responsible angling.''',
            ),
            GuideBlock.section(
              heading: 'Be courteous to others',
              text:
                  '''Give space: Maintain a proper distance from other anglers and give other water users (like swimmers) a wide berth.
Avoid crowding: Do not crowd other anglers or disturb them with your presence or noise.
Share the water: Be cooperative and respectful of other people on the water, including landowners.
Ask permission: Get permission before fishing on private property.''',
            ),
          ],
        ),
      ),
    );
  }

  void openFishingRules(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Fishing Rules',
          headerImage: 'assets/images/law.png',
          blocks: const [
            GuideBlock.section(
              heading: "Important!",
              text:
                  '''Read the updated rules from the resource: https://www.svenskafiskeregler.se
The information bellow updated on 2025-10-22.

In Sweden, a permit (usually a fishing license) is required to fish in most freshwater areas. However, there is one important exception: free hand gear fishing is allowed along the coast and in the five largest lakes — Vänern, Vättern, Mälaren, Hjälmaren, and Storsjön.

Hand gear fishing is defined as fishing with one rod, jig, or similar gear with a maximum of 10 hooks. Fishing without permission is considered poaching and is illegal. It’s important to check the specific rules that apply to the water you’re fishing in, including any minimum size limits and closed seasons.
                  ''',
            ),

            GuideBlock.section(
              heading: 'Key rules to remember:',
              text:
                  '''Permit: A fishing license or other permission from the fishing rights owner is required for freshwater fishing outside the five major lakes.

Free fishing: You may fish freely with hand gear along the coast and in the five large lakes — Vänern, Vättern, Mälaren, Hjälmaren, and Storsjön.
Hand gear: Means a fishing rod, jig, or similar tool with one line and up to 10 hooks.

Local rules: Always check the local fishing regulations. Rules about minimum sizes, closed seasons, and the number of rods may vary.
Fishing for sale: Fishing for commercial purposes is not allowed in recreational fishing.

Private areas: It is forbidden to fish from private docks or properties, and often also from a boat or float tube within 50 meters of them.

Illegal fishing: Fishing without permission is a crime and may result in fines or imprisonment.''',
            ),
          ],
        ),
      ),
    );
  }

  void openGear(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Gear',
          headerImage: 'assets/images/rods.png',
          blocks: const [
            GuideBlock.section(
              heading: 'Purpose',
              text:
                  'Rods and reels work together to cast, control, and retrieve the line. Choosing the right combination depends on your fishing style — such as spinning, trolling, or casting. Each type offers different handling, strength, and precision.',
            ),

            // Spinning setup
            GuideBlock.image(
              asset: 'assets/images/spenning_rods.png',
              caption: 'Classic shore setup with a spinning reel',
            ),
            GuideBlock.section(
              heading: 'Spinning Rods',
              text:
                  'The most common type for shore and pier fishing.\n'
                  'Used with a spinning reel that hangs under the rod.\n'
                  'Ideal for light to medium lures such as spoons, spinners, and soft baits.\n'
                  'Usually 6–10 feet long and flexible at the tip for accurate casts.',
            ),
            GuideBlock.section(
              heading: 'Spinning Reels',
              text:
                  'Easy to use and good for beginners.\n'
                  'The spool does not rotate; the bail arm releases the line during casting.\n'
                  'Mounted under the rod for balance and comfort.\n'
                  'The drag system (front or rear) must be smooth so the line can slip evenly when a fish pulls.\n'
                  'Best for freshwater and light coastal fishing.',
            ),

            // Trolling setup
            GuideBlock.image(
              asset: 'assets/images/trolling.png',
              caption:
                  'Rod + multiplier reel pulling lures behind a moving boat',
            ),
            GuideBlock.section(
              heading: 'Trolling Rods',
              text:
                  'Short, thick, and very strong to handle heavy lines and large fish.\n'
                  'Used from a moving boat to pull lures behind.\n'
                  'Works best with multiplier reels that maintain steady pressure while trolling.',
            ),

            // Casting setup
            GuideBlock.image(
              asset: 'assets/images/baitcaster.png',
              caption: 'Trigger grip and top-mounted reel for precision casts',
            ),
            GuideBlock.section(
              heading: 'Casting Rods',
              text:
                  'Designed for baitcasting reels, which sit on top of the rod.\n'
                  'Provide higher accuracy and more power for heavier lures.\n'
                  'Common in predator and sport fishing.\n'
                  'Can be recognized by their top-mounted reel, small guides, and trigger grip near the reel seat.\n'
                  'Have markings that show length (in feet/inches) and casting weight (in grams).',
            ),
            GuideBlock.section(
              heading: 'Baitcasting / Multiplier Reels',
              text:
                  'The spool rotates during casting, giving better contact with the lure and fish.\n'
                  'Require more skill to control and prevent line tangles.\n'
                  'Offer strong torque and power for fighting big fish.\n'
                  'Often equipped with centrifugal or magnetic brakes to control spool speed.\n'
                  'Two main drag systems:\n'
                  '• Star drag: indirect braking on the spool.\n'
                  '• Lever drag: direct braking with full power.\n'
                  'Commonly used for heavy lures, trolling, or large fish.',
            ),

            // Specs & features
            GuideBlock.section(
              heading: 'Rod Length & Casting Weight',
              text:
                  'Each rod shows:\n'
                  '• Length — in feet and inches (e.g., 7’6”).\n'
                  '• Casting weight — in grams (e.g., 5–25 g).\n'
                  'These markings help you choose the right rod for your lure size and casting distance.',
            ),
            GuideBlock.section(
              heading: 'Reel Features',
              text:
                  'Gear ratio: how many times the spool turns with one handle rotation.\n'
                  'High ratio = faster retrieve.\n'
                  'Low ratio = more power for heavy fish.\n'
                  'Bearings: more bearings mean smoother operation.\n'
                  'Spool shape: affects casting distance and line lay; long cast spools help with longer throws.\n'
                  'Maintenance: clean the reel and change line regularly for best performance.',
            ),
          ],
        ),
      ),
    );
  }

  void openKnots(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailPage(
          title: 'Knots',
          blocks: const [
            GuideBlock.section(
              heading: 'Most popular knots are illustrated bellow. ',
              text: '',
            ),
            GuideBlock.image(
              asset: 'assets/images/knots_2.png',
              caption: 'Zoom in for better look',
            ),
            GuideBlock.image(
              asset: 'assets/images/knots_1.png',
              caption: 'Zoom in for better look',
            ),
          ],
        ),
      ),
    );
  }

  void openLures(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LurePage()));
  }

  void openFishes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FishesPosterPage()),
    );
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
                        case 'Conditions':
                          openConditions(context);
                          break;
                        case 'Tides':
                          openTides(context);
                          break;
                        case 'Stream water':
                          openStreamWater(context);
                          break;
                        case 'Live Baits':
                          openLiveBaits(context);
                          break;
                        case 'Float Fishing':
                          openFloatFishing(context);
                          break;
                        case 'Fishing Ethics':
                          openFishingEthics(context);
                          break;
                        case 'Fishing Rules':
                          openFishingRules(context);
                          break;
                        case 'Gear':
                          openGear(context);
                          break;
                        case 'Lures':
                          openLures(context);
                          break;
                        case 'Fishes':
                          openFishes(context);
                          break;
                        case 'Knots':
                          openKnots(context);
                          break;
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
