import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearchChanged;

  const DashboardAppBar({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Baby Photo Vault',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to family sharing
            context.push('/family');
          },
          icon: const Icon(Icons.family_restroom),
          tooltip: '가족 공유',
        ),
        IconButton(
          onPressed: () {
            // TODO: Navigate to settings
            context.push('/settings');
          },
          icon: const Icon(Icons.settings),
          tooltip: '설정',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
