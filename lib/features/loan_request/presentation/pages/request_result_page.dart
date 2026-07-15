import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pe/app/theme.dart';
import 'package:pe/app/widgets/app_bottom_nav.dart';
import 'package:pe/features/equipment/presentation/providers/equipment_providers.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';

class RequestResultPage extends ConsumerWidget {
  const RequestResultPage({super.key, required this.result});

  final LoanRequestResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = result.payload;
    final deviceAsync = ref.watch(deviceDetailProvider(payload.deviceId));
    final deviceName = deviceAsync.maybeWhen(
      data: (device) => device.name,
      orElse: () => payload.deviceId,
    );

    final borrow = payload.borrowDate;
    final ret = payload.returnDate;
    final periodLabel = _formatLoanPeriod(borrow, ret);
    final statusLabel = result.isPending
        ? 'Pending (offline)'
        : (payload.status == 'pending' ? 'Pending approval' : payload.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.isPending ? Icons.hourglass_top : Icons.check,
                color: AppColors.primary,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            result.isPending ? 'Loan request saved offline' : 'Loan request created',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            result.id != null
                ? 'Request ID #${result.id}'
                : 'Queued for sync when you are back online',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (result.isPending) ...[
            const SizedBox(height: 12),
            const Text(
              'No connection — this request has been saved locally and will be '
              'sent automatically once the network is back.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ResultRow('Device', deviceName, valueColor: AppColors.textPrimary),
                _ResultRow('Loan period', periodLabel, valueColor: AppColors.textPrimary),
                _ResultRow(
                  'Deposit',
                  '\$${payload.deposit.toStringAsFixed(0)}',
                  valueColor: AppColors.primary,
                ),
                _ResultRow('Status', statusLabel, valueColor: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('BACK TO DEVICES'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  String _formatLoanPeriod(DateTime borrow, DateTime ret) {
    if (borrow.year == ret.year && borrow.month == ret.month) {
      final month = DateFormat('MMM').format(borrow);
      return '${DateFormat('dd').format(borrow)}-${DateFormat('dd').format(ret)} $month';
    }
    final fmt = DateFormat('dd MMM');
    return '${fmt.format(borrow)} – ${fmt.format(ret)}';
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value, {required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
