import 'package:flutter/material.dart';

import '../../data/models/location_model.dart';

class LocationSearchScreen extends StatefulWidget {
  final String title;
  final String hint;

  const LocationSearchScreen({
    super.key,
    required this.title,
    required this.hint,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _results = [];
  bool _isSearching = false;

  // Mock recent locations
  final List<LocationModel> _recentLocations = const [
    LocationModel(
      latitude: 10.7769,
      longitude: 106.7009,
      name: 'Ben Thanh Market',
      address: '1 Cong Truong Ben Thanh, District 1, HCMC',
    ),
    LocationModel(
      latitude: 10.7956,
      longitude: 106.7218,
      name: 'Tan Son Nhat Airport',
      address: 'Truong Son, Tan Binh District, HCMC',
    ),
    LocationModel(
      latitude: 10.7743,
      longitude: 106.6985,
      name: 'Reunification Palace',
      address: '135 Nam Ky Khoi Nghia, District 1, HCMC',
    ),
    LocationModel(
      latitude: 10.7829,
      longitude: 106.6956,
      name: 'Notre-Dame Cathedral',
      address: '1 Cong Xa Paris, District 1, HCMC',
    ),
  ];

  // Mock search results
  final List<LocationModel> _mockSearchResults = const [
    LocationModel(
      latitude: 10.7300,
      longitude: 106.6997,
      name: 'Phu My Hung',
      address: 'Nguyen Van Linh, District 7, HCMC',
    ),
    LocationModel(
      latitude: 10.8411,
      longitude: 106.8098,
      name: 'Thu Duc City',
      address: 'Vo Van Ngan, Thu Duc, HCMC',
    ),
    LocationModel(
      latitude: 10.8231,
      longitude: 106.6297,
      name: 'Binh Duong Province',
      address: 'Thu Dau Mot, Binh Duong',
    ),
    LocationModel(
      latitude: 10.9804,
      longitude: 106.6519,
      name: 'Bien Hoa',
      address: 'Bien Hoa City, Dong Nai',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Debounce with a short delay then filter mock data
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final filtered = _mockSearchResults
          .where((loc) =>
              (loc.name?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (loc.address?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
      setState(() {
        _results = filtered;
        _isSearching = false;
      });
    });
  }

  void _selectLocation(LocationModel location) {
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showRecent = _searchController.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (showRecent) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Recent Locations',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ..._recentLocations.map(
                      (loc) => _LocationTile(
                        location: loc,
                        icon: Icons.history,
                        onTap: () => _selectLocation(loc),
                      ),
                    ),
                  ] else ...[
                    if (_results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No results found'),
                        ),
                      )
                    else
                      ..._results.map(
                        (loc) => _LocationTile(
                          location: loc,
                          icon: Icons.location_on_outlined,
                          onTap: () => _selectLocation(loc),
                        ),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final IconData icon;
  final VoidCallback onTap;

  const _LocationTile({
    required this.location,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        location.name ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        location.address ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      onTap: onTap,
    );
  }
}
