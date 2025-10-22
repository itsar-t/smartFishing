import 'package:flutter/material.dart';
import 'package:smart_fishing/utils/utils.dart';

/// Private enum for the popup menu actions.
enum _AccountMenuAction { profile, signOut }

/// A small avatar that opens an account menu when tapped.
class AccountAvatarMenu extends StatelessWidget {
  final String? username;
  final VoidCallback onSignOut;
  final VoidCallback? onOpenProfile;

  const AccountAvatarMenu({
    super.key,
    required this.username,
    required this.onSignOut,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountMenuAction>(
      tooltip: 'Account',
      offset: const Offset(0, 50), // placerar menyn under avataren
      onSelected: (action) {
        switch (action) {
          case _AccountMenuAction.profile:
            onOpenProfile?.call();
            break;
          case _AccountMenuAction.signOut:
            onSignOut();
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<_AccountMenuAction>>[
        PopupMenuItem<_AccountMenuAction>(
          value: null,
          enabled: false,
          onTap: null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DefaultTextStyle(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,

                  child: Text(
                    username![0].toUpperCase(), // 👈 Detta behövdes
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(capitalize(username)),
              ],
            ),
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem<_AccountMenuAction>(
          value: _AccountMenuAction.profile,
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile & Settings'),
          ),
        ),

        const PopupMenuItem<_AccountMenuAction>(
          value: _AccountMenuAction.signOut,
          child: ListTile(leading: Icon(Icons.logout), title: Text('Sign Out')),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          child: Text(
            (username?.isNotEmpty ?? false) ? username![0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
