import 'package:flutter/material.dart';
import '../widgets/guide_blocks.dart';

class GuideDetailPage extends StatelessWidget {
  final String title; // t.ex. "Tides"
  final String? headerImage; // stor toppbild (1:1 eller 16:9 funkar)
  final List<GuideBlock> blocks; // innehållet: sektioner och bilder

  const GuideDetailPage({
    super.key,
    required this.title,
    this.headerImage,
    required this.blocks,
  });

  static const double _hPad = 16;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title), // "Tides", "Stream Water", etc.
        backgroundColor: cs.primary, // som New post
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🔹 Toppbild (full-bleed känsla, med rundade hörn)
          // 🔹 Toppbild – full width, visar hela bilden (contain)
          // 🔹 Toppbild – fyller hela skärmens bredd och visar hela bilden
          if (headerImage != null && headerImage!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                headerImage!,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),

          // 🔹 Innehåll
          Padding(
            padding: const EdgeInsets.fromLTRB(_hPad, 4, _hPad, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final b in blocks)
                  b.isImage
                      ? GuideImage(asset: b.asset!, caption: b.caption)
                      : GuideSection(heading: b.heading!, text: b.text!),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
