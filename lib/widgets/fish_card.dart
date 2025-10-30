import 'package:flutter/material.dart';

class FishCard extends StatelessWidget {
  final String name; // ex. "Perch"
  final String asset; // ex. 'assets/images/fish/perch.png'
  final VoidCallback? onTap; // valfritt (öppna detaljer)

  const FishCard({
    super.key,
    required this.name,
    required this.asset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bild med rundade hörn, bevarar proportioner
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.asset(
              asset,
              fit: BoxFit.contain, // visar hela fisken utan att klippa
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );

    // Gör hela rutan tryckbar om onTap finns
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(8.0), child: card),
      ),
    );
  }
}
