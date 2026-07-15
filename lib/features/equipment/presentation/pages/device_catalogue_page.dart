import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe/app/route_names.dart';
import 'package:pe/app/theme.dart';
import 'package:pe/app/widgets/app_bottom_nav.dart';
import 'package:pe/features/equipment/presentation/providers/equipment_providers.dart';
import 'package:pe/features/equipment/presentation/widgets/device_card.dart';
import 'package:pe/features/equipment/presentation/widgets/offline_banner.dart';

class DeviceCataloguePage extends ConsumerStatefulWidget {
  const DeviceCataloguePage({super.key});

  @override
  ConsumerState<DeviceCataloguePage> createState() => _DeviceCataloguePageState();
}

class _DeviceCataloguePageState extends ConsumerState<DeviceCataloguePage> {
  final _searchController = TextEditingController();

  static const _filters = <(String label, String value)>[
    ('All', ''),
    ('Laptop', 'Laptop'),
    ('Phone', 'Phone'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(equipmentListProvider);
    final compareIds = ref.watch(compareListProvider);
    final category = ref.watch(categoryFilterProvider);
    final sort = ref.watch(sortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Equipment'),
        actions: [
          PopupMenuButton<SortOption>(
            initialValue: sort,
            icon: const Icon(Icons.sort),
            onSelected: (value) => ref.read(sortOptionProvider.notifier).state = value,
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortOption.none, child: Text('Original order')),
              PopupMenuItem(value: SortOption.depositLowToHigh, child: Text('Deposit: Low to High')),
              PopupMenuItem(value: SortOption.nameAToZ, child: Text('Name: A to Z')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search devices',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchInputProvider.notifier).state = '';
                          ref.read(searchQueryProvider.notifier).clear();
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (value) {
                ref.read(searchInputProvider.notifier).state = value;
                ref.read(searchQueryProvider.notifier).setQuery(value);
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (label, value) = _filters[index];
                final selected = category == value;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                  onSelected: (_) => ref.read(categoryFilterProvider.notifier).state = value,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: error.toString(),
                onRetry: () => ref.read(equipmentListProvider.notifier).refresh(),
              ),
              data: (state) {
                final devices = ref.watch(filteredDevicesProvider);
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(equipmentListProvider.notifier).refresh(),
                  child: Column(
                    children: [
                      if (state.isFromCache) const OfflineBanner(),
                      Expanded(
                        child: devices.isEmpty
                            ? const _EmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 12),
                                itemCount: devices.length,
                                itemBuilder: (context, index) {
                                  final device = devices[index];
                                  return DeviceCard(
                                    device: device,
                                    isComparing: compareIds.contains(device.id),
                                    onToggleCompare: () =>
                                        ref.read(compareListProvider.notifier).toggle(device.id),
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      RouteNames.detail,
                                      arguments: device.id,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.compare),
              child: Text(
                compareIds.isEmpty
                    ? 'VIEW WATCHLIST'
                    : 'VIEW WATCHLIST (${compareIds.length})',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
        SizedBox(height: 12),
        Center(
          child: Text('No devices found', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
