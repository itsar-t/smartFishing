// lib/widgets/fish_info_card.dart
import 'package:flutter/material.dart';

class FishInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String? imageAsset; // valfri bild (asset)

  const FishInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ingen Material, ingen SafeArea/yttre Padding, inga hörn
      color: Theme.of(context).colorScheme.surface, // eller Colors.white
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),

            if (imageAsset != null) ...[
              const SizedBox(height: 6),

              // Croppa bort “tomma” kanter och få bilden högre upp
              ClipRect(
                child: AspectRatio(
                  aspectRatio:
                      16 /
                      5, // lägre höjd => mer crop (justera t.ex. 16/4.5, 16/6)
                  child: Image.asset(
                    imageAsset!,
                    fit: BoxFit.cover, // fyller & croppar
                    alignment: Alignment
                        .center, // justera t.ex. Alignment(0, -0.2) om du vill lyfta upp mer
                  ),
                ),
              ),

              const SizedBox(height: 8), // tight mellanrum till texten
            ],

            Text(
              description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
