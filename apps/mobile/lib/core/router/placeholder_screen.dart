import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Friendly placeholder shown for routes that are wired but whose UI is still
/// being built. Replaces the ugly "Coming soon" tiles with a consistent screen.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? ctaLabel;
  final String? ctaRoute;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.construction,
    this.ctaLabel,
    this.ctaRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (ctaLabel != null && ctaRoute != null)
                ElevatedButton(
                  onPressed: () => context.go(ctaRoute!),
                  child: Text(ctaLabel!),
                )
              else
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
