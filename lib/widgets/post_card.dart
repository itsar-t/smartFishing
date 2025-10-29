// lib/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:smart_fishing/utils/capitalize.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String meta; // e.g. "2h • Hovås – Sea"
  final ImageProvider image; // NetworkImage / AssetImage
  final String? description; // 👈 NYTT: valfritt
  final VoidCallback? onFollow;
  final VoidCallback? onOverflow;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool liked;

  const PostCard({
    super.key,
    required this.username,
    required this.meta,
    required this.image,
    this.description,
    this.onFollow,
    this.onOverflow,
    this.onLike,
    this.onComment,
    this.onShare,
    this.liked = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _expanded = false;

  // Enkel heuristik för “lång text” (undvik dyra layoutmätningar).
  bool get _isLong =>
      (widget.description?.trim().length ?? 0) >
      140; // justera gräns om du vill

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDesc =
        (widget.description != null) && widget.description!.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withAlpha((0.08 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.inversePrimary,
                  child: Text(
                    (widget.username.isNotEmpty ? widget.username[0] : '?')
                        .toUpperCase(),
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalize(widget.username),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                      ),
                      Text(
                        widget.meta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: FilledButton.tonal(
                    onPressed: widget.onFollow,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                    ),
                    child: const Text('Follow'),
                  ),
                ),
                IconButton(
                  onPressed: widget.onOverflow,
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          // Image
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Ink.image(image: widget.image, fit: BoxFit.cover),
          ),

          // Description (valfri)
          if (hasDesc) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(
                widget.description!.trim(),
                maxLines: _expanded ? null : 3,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ),
            if (_isLong)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(_expanded ? 'Show less' : 'Read more'),
                ),
              ),
            const SizedBox(height: 4),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Action(
                  icon: widget.liked ? Icons.favorite : Icons.favorite_border,
                  label: 'Like',
                  isPrimary: widget.liked,
                  onTap: widget.onLike,
                ),
                _Action(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comment',
                  onTap: widget.onComment,
                ),
                _Action(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: widget.onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _Action({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isPrimary ? cs.primary : cs.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isPrimary ? cs.primary : cs.onSurface,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
