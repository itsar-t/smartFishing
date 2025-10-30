import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CountyLicencePage extends StatelessWidget {
  const CountyLicencePage({super.key, required this.countyName});
  final String countyName;

  @override
  Widget build(BuildContext context) {
    final isGotland = countyName == 'Gotlands län';

    final gotlandFisheries = <FisheryArea>[
      FisheryArea(
        municipality: 'Etelhem',
        name: 'Etelhem Fiskekortsområde',
        buyUrl: 'https://www.ifiske.se/fiskekort-etelhem.htm',
      ),

      FisheryArea(
        municipality: 'Gothemsån Åminne',
        name: 'Sportfiskarna Gotland',
        buyUrl: 'https://www.ifiske.se/fiskekort-gothemsan-aminne.htm',
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/fishing-app-cls055.firebasestorage.app/o/ocean.png?alt=media&token=f23fe6b7-60a9-441d-88b7-bad62b08854d',
      ),
      FisheryArea(
        municipality: 'Närsån',
        name: 'Närsån FVO',
        buyUrl: 'https://www.ifiske.se/fiskekort-narsan.htm',
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/fishing-app-cls055.firebasestorage.app/o/ChatGPT%20Image%2030%20okt.%202025%2003_30_15.png?alt=media&token=e2c6b4e8-5b42-4c1c-b64b-8f3681358c8f',
      ),
      FisheryArea(
        municipality: 'Wadet',
        name: 'Wadets fiskekortsområde',
        buyUrl: 'https://www.ifiske.se/fiskekort-wadet.htm',
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/fishing-app-cls055.firebasestorage.app/o/ChatGPT%20Image%2030%20okt.%202025%2003_52_37.png?alt=media&token=a9923b19-2acc-4947-9469-9cf93098802a',
      ),
    ];

    // Placeholder-lista för andra län tills de designas
    final placeholder = <FisheryArea>[
      FisheryArea(
        municipality: countyName,
        name: 'Fiskeområden kommer snart',
        buyUrl: "",
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/fishing-app-cls055.firebasestorage.app/o/ChatGPT%20Image%2030%20okt.%202025%2003_57_13.png?alt=media&token=f8bc29d8-dcb8-4a21-b65d-06d9055a18d8',
      ),
    ];

    final items = isGotland ? gotlandFisheries : placeholder;

    return Scaffold(
      appBar: AppBar(
        title: Text(countyName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) => FisheryTile(area: items[i]),
      ),
    );
  }
}

/// Enkel modell
class FisheryArea {
  final String municipality;
  final String name;
  final String buyUrl;
  final String infoUrl;
  final String? description;
  final String? imageUrl;

  FisheryArea({
    required this.municipality,
    required this.name,
    required this.buyUrl,
    this.description,
    this.imageUrl,
  }) : infoUrl = _deriveInfoUrl(buyUrl);

  static String _deriveInfoUrl(String buyUrl) {
    // Exempel: https://www.ifiske.se/fiskekort-wadet.htm
    // ->        https://www.ifiske.se/wadet.htm
    return buyUrl.replaceFirst('fiskekort-', 'fiske-');
  }
}

/// Expandable list-rad som matchar mockup
class FisheryTile extends StatelessWidget {
  const FisheryTile({super.key, required this.area});
  final FisheryArea area;

  @override
  Widget build(BuildContext context) {
    // Leading square placeholder (56x56)
    Widget _leadingImage(BuildContext context) {
      const double size = 56;
      const String defaultImage = 'assets/images/place.png';
      final String? rawUrl = area.imageUrl;

      Future<String> resolveUrl() async {
        if (rawUrl == null || rawUrl.isEmpty) return defaultImage;

        if (rawUrl.startsWith('http')) return rawUrl;

        if (rawUrl.startsWith('gs://')) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(rawUrl);
            return await ref.getDownloadURL();
          } catch (e) {
            debugPrint('⚠️ Misslyckades ladda Firebase-bild: $e');
            return defaultImage;
          }
        }

        return defaultImage;
      }

      Widget _buildShimmerPlaceholder() {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.grey.shade300),
        );
      }

      return FutureBuilder<String>(
        future: resolveUrl(),
        builder: (context, snapshot) {
          final imagePath = snapshot.data;
          final isNetworkImage = (imagePath?.startsWith('http') ?? false);

          return Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: switch (snapshot.connectionState) {
                ConnectionState.waiting => _buildShimmerPlaceholder(),
                _ =>
                  isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: imagePath!,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 400),
                          placeholder: (_, __) => _buildShimmerPlaceholder(),
                          errorWidget: (_, __, ___) =>
                              Image.asset(defaultImage, fit: BoxFit.cover),
                        )
                      : Image.asset(defaultImage, fit: BoxFit.cover),
              },
            ),
          );
        },
      );
    }

    // Titel + undertitel som i din skiss
    Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          area.municipality,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          area.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Theme(
      // Tar bort ExpansionTile’s default divider/padding
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.fromLTRB(84, 0, 16, 12),
        leading: _leadingImage(context),
        title: titleBlock,
        trailing: const Icon(Icons.chevron_right),
        collapsedIconColor: Colors.transparent, // vi använder chevron_right
        iconColor: Colors.transparent, // och döljer default-ikon
        children: [
          // Innehåll när expanded: knappar + (valfri) beskrivning
          if ((area.description ?? '').isNotEmpty) ...[
            Text(area.description!),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('Regler & info'),
                onPressed: () async {
                  final uri = Uri.parse(area.infoUrl);
                  final ok = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kunde inte öppna ${area.infoUrl}'),
                      ),
                    );
                  }
                },
              ),

              FilledButton.icon(
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Köp via iFiske.se'),
                onPressed: () async {
                  final url = area.buyUrl;
                  if (url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingen köp-länk tillgänglig.'),
                      ),
                    );
                    return;
                  }
                  final uri = Uri.parse(url);
                  // Öppna i extern webbläsare (bäst för betalning)
                  final ok = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kunde inte öppna länken.')),
                    );
                  }
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.bookmark_border),
                label: const Text('Spara'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sparade "${area.name}"')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
