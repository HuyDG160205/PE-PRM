import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pe/app/route_names.dart';
import 'package:pe/app/theme.dart';
import 'package:pe/app/widgets/app_bottom_nav.dart';
import 'package:pe/core/utils/date_validator_rules.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';
import 'package:pe/features/equipment/presentation/providers/equipment_providers.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';
import 'package:pe/features/loan_request/domain/usecases/validate_loan_period.dart';
import 'package:pe/features/loan_request/presentation/providers/loan_request_providers.dart';

class LoanRequestFormPage extends ConsumerWidget {
  const LoanRequestFormPage({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceDetailProvider(deviceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Request')),
      body: deviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (device) => _LoanFormBody(device: device),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _LoanFormBody extends ConsumerWidget {
  const _LoanFormBody({required this.device});

  final Equipment device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = (deviceId: device.id, deposit: device.deposit);
    final state = ref.watch(loanFormProvider(formKey));
    final notifier = ref.read(loanFormProvider(formKey).notifier);
    final dateFormat = DateFormat('dd MMM yyyy');

    final borrow = state.draft.borrowDate;
    final returnDate = state.draft.returnDate;
    final periodDays = (borrow != null && returnDate != null)
        ? DateValidatorRules.periodInDays(borrow, returnDate)
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _LabeledField(
          label: 'Student ID',
          errorText: state.studentIdError,
          child: TextField(
            key: const Key('student_id_field'),
            decoration: const InputDecoration(hintText: 'e.g. SE1819'),
            onChanged: notifier.setStudentId,
          ),
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: 'Borrow date',
          child: _DatePickerField(
            date: state.draft.borrowDate,
            formatted: state.draft.borrowDate != null
                ? dateFormat.format(state.draft.borrowDate!)
                : null,
            onPick: notifier.setBorrowDate,
          ),
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: 'Return date',
          child: _DatePickerField(
            date: state.draft.returnDate,
            formatted: state.draft.returnDate != null
                ? dateFormat.format(state.draft.returnDate!)
                : null,
            onPick: notifier.setReturnDate,
          ),
        ),
        if (state.dateError != null) ...[
          const SizedBox(height: 8),
          Text(state.dateError!.message, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        _LabeledField(
          label: 'Purpose',
          errorText: state.purposeError,
          child: TextField(
            key: const Key('purpose_field'),
            decoration: const InputDecoration(hintText: 'Reason for borrowing'),
            onChanged: notifier.setPurpose,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.summaryBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request summary',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                label: 'Loan period',
                value: periodDays == null ? '—' : '$periodDays days',
                valueColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Refundable deposit',
                value: '\$${device.deposit.toStringAsFixed(0)}',
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ),
        if (state.submitFailureMessage != null) ...[
          const SizedBox(height: 12),
          Text(state.submitFailureMessage!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: (!state.isValid || state.isSubmitting)
              ? null
              : () => _handleSubmit(context, notifier),
          child: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('SUBMIT LOAN REQUEST'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context, LoanFormNotifier notifier) async {
    final result = await notifier.submit();
    if (result == null || !context.mounted) return;
    if (result is Success<LoanRequestResult>) {
      Navigator.pushReplacementNamed(context, RouteNames.requestResult, arguments: result.value);
    }
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.errorText,
  });

  final String label;
  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.primaryDark, fontSize: 14)),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.date,
    required this.formatted,
    required this.onPick,
  });

  final DateTime? date;
  final String? formatted;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(),
        child: Text(
          formatted ?? 'Select date',
          style: TextStyle(
            color: formatted == null ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
