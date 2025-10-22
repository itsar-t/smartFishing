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
    final double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Material(
          color: Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            // 🟣 Fast höjd på kortet — t.ex. 60% av skärmen
            height: screenHeight * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // rubrik + undertitel
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    if (imageAsset != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imageAsset!,
                          fit: BoxFit.contain, // 🔥 Fyller ut hela ytan snyggt
                          alignment: Alignment.center,
                          width: double
                              .infinity, // Gör bilden lika bred som kortet
                          height: 180, // Ger lagom höjd
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
