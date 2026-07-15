import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';
import 'package:pe/features/equipment/domain/repositories/equipment_repository.dart';
import 'package:pe/features/equipment/presentation/providers/equipment_providers.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_draft.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';
import 'package:pe/features/loan_request/domain/repositories/loan_request_repository.dart';
import 'package:pe/features/loan_request/presentation/pages/loan_request_form_page.dart';
import 'package:pe/features/loan_request/presentation/providers/loan_request_providers.dart';

class FakeEquipmentRepository implements EquipmentRepository {
  @override
  Future<Result<Equipment>> getDeviceById(String id) async {
    return Success(
      Equipment(id: id, name: 'Test Laptop', rawData: const {'price': 200}, price: 200),
    );
  }

  @override
  Future<Result<EquipmentListResult>> getDevices() async {
    return const Success(EquipmentListResult(devices: [], isFromCache: false));
  }
}

/// Counts how many times a POST would have been made so the test can assert
/// that rapid taps on Submit only ever trigger a single call.
class FakeLoanRequestRepository implements LoanRequestRepository {
  int submitCallCount = 0;

  @override
  Future<Result<LoanRequestResult>> submit(LoanRequestPayload payload) async {
    submitCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));
    return Success(
      LoanRequestResult(payload: payload, isPending: false, id: 'fake-id', createdAt: DateTime.now()),
    );
  }

  @override
  Future<void> retryPendingRequests() async {}

  @override
  Future<void> saveDraft(LoanRequestDraft draft) async {}

  @override
  Future<LoanRequestDraft?> loadDraft() async => null;

  @override
  Future<void> clearDraft() async {}
}

void main() {
  testWidgets('rapid Submit taps only trigger a single POST call', (tester) async {
    final fakeLoanRepository = FakeLoanRequestRepository();
    const deviceId = 'device-1';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          equipmentRepositoryProvider.overrideWithValue(FakeEquipmentRepository()),
          loanRequestRepositoryProvider.overrideWithValue(fakeLoanRepository),
        ],
        child: MaterialApp(
          home: const LoanRequestFormPage(deviceId: deviceId),
          onGenerateRoute: (settings) =>
              MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Result'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('student_id_field')), 'SE1819');
    await tester.enterText(find.byKey(const Key('purpose_field')), 'Mobile app demo');

    // Set valid dates directly through the notifier (bypassing the date
    // picker dialog, which is not the focus of this test).
    final element = tester.element(find.byType(LoanRequestFormPage));
    final container = ProviderScope.containerOf(element);
    final key = (deviceId: deviceId, deposit: 50.0);
    container.read(loanFormProvider(key).notifier).setBorrowDate(DateTime(2026, 8, 1));
    container.read(loanFormProvider(key).notifier).setReturnDate(DateTime(2026, 8, 5));
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, 'SUBMIT LOAN REQUEST');
    expect(submitButton, findsOneWidget);

    // Tap rapidly without waiting for the first submission to finish.
    await tester.tap(submitButton);
    await tester.tap(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(fakeLoanRepository.submitCallCount, 1);
  });
}
