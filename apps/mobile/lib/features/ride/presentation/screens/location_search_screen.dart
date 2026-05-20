import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/empty_state.dart';
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
    final cs = theme.colorScheme;
    final showRecent = _searchController.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _searchController.text.isEmpty
                      ? Colors.transparent
                      : cs.primary,
                  width: 1.4,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: cs.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  if (showRecent) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded,
                              size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            'Recent locations',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._recentLocations.map(
                      (loc) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LocationTile(
                          location: loc,
                          icon: Icons.history_rounded,
                          onTap: () => _selectLocation(loc),
                        ),
                      ),
                    ),
                  ] else ...[
                    if (_results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matches',
                          subtitle: 'Try a different keyword or address.',
                        ),
                      )
                    else
                      ..._results.map(
                        (loc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LocationTile(
                            location: loc,
                            icon: Icons.location_on_rounded,
                            onTap: () => _selectLocation(loc),
                          ),
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
    final cs = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name ?? 'Unknown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.address != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        location.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
