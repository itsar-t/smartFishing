import 'package:flutter/material.dart';

/// Ett innehållsblock: antingen textsektion eller bild.
class GuideBlock {
  final String? heading;
  final String? text;
  final String? asset;
  final String? caption;
  final bool isImage;

  const GuideBlock.section({required this.heading, required this.text})
    : asset = null,
      caption = null,
      isImage = false;

  const GuideBlock.image({required this.asset, this.caption})
    : heading = null,
      text = null,
      isImage = true;
}

/// Sektion med rubrik + brödtext.
class GuideSection extends StatelessWidget {
  final String heading;
  final String text;
  const GuideSection({super.key, required this.heading, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(height: 1.35, color: cs.onSurface.withOpacity(.9)),
          ),
        ],
      ),
    );
  }
}

/// Bildblock för mellanbilder i innehållet (med valfri bildtext).
class GuideImage extends StatelessWidget {
  final String asset;
  final String? caption;
  const GuideImage({super.key, required this.asset, this.caption});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
