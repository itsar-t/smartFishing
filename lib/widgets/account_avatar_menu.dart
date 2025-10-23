import 'package:flutter/material.dart';
import 'package:smart_fishing/utils/capitalize.dart';

class AccountAvatarMenu extends StatelessWidget {
  final String username;
  final VoidCallback onSignOut;
  final VoidCallback onOpenProfile;
  final bool isGuest;
  final VoidCallback? onUpgrade; // visas bara om isGuest = true

  const AccountAvatarMenu({
    super.key,
    required this.username,
    required this.onSignOut,
    required this.onOpenProfile,
    this.isGuest = false,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.8);

    return PopupMenuButton<_MenuAction>(
      tooltip: 'Konto',
      offset: const Offset(0, kToolbarHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_MenuAction>>[
          // 👇 HEADER – ej klickbar
          PopupMenuItem<_MenuAction>(
            enabled: false,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  capitalize(username),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const PopupMenuDivider(),

          PopupMenuItem<_MenuAction>(
            value: _MenuAction.profile,
            enabled: !isGuest,
            child: Row(
              children: [
                Icon(Icons.person, size: 20, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  isGuest ? 'Profil (kräver konto)' : 'Profil',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          if (isGuest && onUpgrade != null) const PopupMenuDivider(),
          if (isGuest && onUpgrade != null)
            PopupMenuItem<_MenuAction>(
              value: _MenuAction.upgrade,
              child: Row(
                children: [
                  Icon(Icons.upgrade, size: 20, color: iconColor),
                  const SizedBox(width: 10),
                  Text(
                    'Uppgradera konto…',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

          const PopupMenuDivider(),
          PopupMenuItem<_MenuAction>(
            value: _MenuAction.signOut,
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  'Logga ut',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ];
        return items;
      },
      onSelected: (action) {
        switch (action) {
          case _MenuAction.profile:
            onOpenProfile();
            break;
          case _MenuAction.upgrade:
            if (onUpgrade != null) onUpgrade!();
            break;
          case _MenuAction.signOut:
            onSignOut();
            break;
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.9),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

enum _MenuAction { profile, upgrade, signOut }
