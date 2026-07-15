import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe/app/route_names.dart';
import 'package:pe/app/theme.dart';
import 'package:pe/app/widgets/app_bottom_nav.dart';
import 'package:pe/core/utils/date_validator_rules.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';
import 'package:pe/features/equipment/presentation/providers/equipment_providers.dart';

class DeviceDetailPage extends ConsumerWidget {
  const DeviceDetailPage({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceDetailProvider(deviceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Device Detail')),
      body: deviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (device) => _DeviceDetailBody(device: device),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _DeviceDetailBody extends StatelessWidget {
  const _DeviceDetailBody({required this.device});

  final Equipment device;

  @override
  Widget build(BuildContext context) {
    final yearLabel = device.hasYear ? 'Year ${device.year}' : 'Unknown year';
    final cpu = _lookupRaw(device, const ['CPU', 'cpu', 'processor', 'Processor']);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          height: 180,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.imagePlaceholder,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'DEVICE IMAGE',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          device.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${device.category} • $yearLabel',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Text(
          device.hasPrice
              ? 'Estimated value: \$${device.price!.toStringAsFixed(0)}'
              : 'Estimated value: Not available',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SpecBlock(
                  label: 'CPU',
                  value: cpu ?? 'Not available',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _SpecBlock(
                  label: 'Deposit',
                  value: '\$${device.deposit.toStringAsFixed(0)}',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Loan policy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Maximum loan period is ${DateValidatorRules.maxLoanDays} days. '
          'The request remains pending until staff approval.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.pushNamed(
            context,
            RouteNames.loanForm,
            arguments: device.id,
          ),
          child: const Text('REQUEST THIS DEVICE'),
        ),
      ],
    );
  }

  String? _lookupRaw(Equipment device, List<String> keys) {
    final data = device.rawData;
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}

class _SpecBlock extends StatelessWidget {
  const _SpecBlock({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}
