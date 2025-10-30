import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

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

class GuideSection extends StatelessWidget {
  final String heading;
  final String text;
  const GuideSection({super.key, required this.heading, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Helper to open URLs
    Future<void> _openUrl(String urlString) async {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }

    // Detect if text contains a link
    final RegExp linkRegExp = RegExp(r'(https?:\/\/[^\s]+)');
    final List<TextSpan> spans = [];
    int last = 0;
    for (final match in linkRegExp.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(
            color: cs.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _openUrl(url),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }

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
          RichText(
            text: TextSpan(
              style: TextStyle(
                height: 1.35,
                color: cs.onSurface.withOpacity(.9),
                fontSize: 14,
              ),
              children: spans,
            ),
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

    // Identifiera "instruktions-/diagram"-bilder
    final bool isDiagram =
        asset.contains('knots') ||
        asset.contains('diagram') ||
        asset.contains('infographic');

    // Välj bildwidget
    final Widget image = Image.asset(
      asset,
      fit: isDiagram ? BoxFit.contain : BoxFit.cover,
      alignment: Alignment.center,
    );

    // Om det är en diagrambild → gör den zoombar
    final Widget imageContainer = isDiagram
        ? InteractiveViewer(
            clipBehavior: Clip.none,
            panEnabled: true,
            minScale: 1,
            maxScale: 4, // 🔍 zoomnivå
            child: image,
          )
        : AspectRatio(
            aspectRatio: 16 / 9, // 📸 enhetligt för vanliga bilder
            child: image,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageContainer,
          ),
          if (caption != null && caption!.isNotEmpty) ...[
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
