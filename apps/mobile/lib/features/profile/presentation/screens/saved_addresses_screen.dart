import 'package:flutter/material.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Home', 'Add your home address', Icons.home_rounded),
      ('Work', 'Add your work address', Icons.business_center_rounded),
      ('Favorites', 'Places you use often', Icons.star_rounded),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading:
                Icon(item.$3, color: Theme.of(context).colorScheme.primary),
            title: Text(item.$1),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.add_rounded),
          );
        },
      ),
    );
  }
}
