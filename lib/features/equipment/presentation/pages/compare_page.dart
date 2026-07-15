import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe/features/equipment/presentation/providers/equipment_providers.dart';

/// Simple side-by-side comparison of the (at most 2) devices selected from
/// the catalogue. The two-device cap itself is enforced in
/// [CompareListNotifier.toggle], not here.
class ComparePage extends ConsumerWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds = ref.watch(compareListProvider);
    final listState = ref.watch(equipmentListProvider).valueOrNull;
    final devices = (listState?.devices ?? []).where((d) => compareIds.contains(d.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: devices.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bookmark up to 2 devices from Explore to compare them here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Row(
              children: devices
                  .map(
                    (device) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(device.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text('Category: ${device.category}'),
                                Text('Year: ${device.hasYear ? device.year : 'N/A'}'),
                                Text('Price: ${device.hasPrice ? '\$${device.price!.toStringAsFixed(0)}' : 'N/A'}'),
                                Text('Deposit: \$${device.deposit.toStringAsFixed(0)}'),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () =>
                                      ref.read(compareListProvider.notifier).toggle(device.id),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
