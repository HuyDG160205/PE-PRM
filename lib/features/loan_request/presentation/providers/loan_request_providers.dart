import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe/app/providers.dart';
import 'package:pe/core/utils/result.dart';
import 'package:pe/features/loan_request/data/datasources/loan_request_local_data_source.dart';
import 'package:pe/features/loan_request/data/datasources/loan_request_remote_data_source.dart';
import 'package:pe/features/loan_request/data/repositories/loan_request_repository_impl.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_draft.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_payload.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';
import 'package:pe/features/loan_request/domain/repositories/loan_request_repository.dart';
import 'package:pe/features/loan_request/domain/usecases/retry_pending_requests.dart';
import 'package:pe/features/loan_request/domain/usecases/submit_loan_request.dart';
import 'package:pe/features/loan_request/domain/usecases/validate_loan_period.dart';

final loanRequestRemoteDataSourceProvider = Provider<LoanRequestRemoteDataSource>((ref) {
  return LoanRequestRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final loanRequestLocalDataSourceProvider = Provider<LoanRequestLocalDataSource>((ref) {
  return LoanRequestLocalDataSourceImpl(ref.watch(localStorageProvider));
});

final loanRequestRepositoryProvider = Provider<LoanRequestRepository>((ref) {
  return LoanRequestRepositoryImpl(
    remoteDataSource: ref.watch(loanRequestRemoteDataSourceProvider),
    localDataSource: ref.watch(loanRequestLocalDataSourceProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final submitLoanRequestProvider = Provider<SubmitLoanRequest>((ref) {
  return SubmitLoanRequest(ref.watch(loanRequestRepositoryProvider));
});

final validateLoanPeriodProvider = Provider<ValidateLoanPeriod>((ref) => const ValidateLoanPeriod());

final retryPendingRequestsProvider = Provider<RetryPendingRequests>((ref) {
  return RetryPendingRequests(ref.watch(loanRequestRepositoryProvider));
});

/// Key identifying which device's form is currently open and the deposit to
/// charge for it (resolved by the page once the device has loaded).
typedef LoanFormKey = ({String deviceId, double deposit});

class LoanFormState {
  const LoanFormState({
    required this.draft,
    this.dateError,
    this.studentIdError,
    this.purposeError,
    this.isSubmitting = false,
    this.submitFailureMessage,
  });

  final LoanRequestDraft draft;
  final LoanDateError? dateError;
  final String? studentIdError;
  final String? purposeError;
  final bool isSubmitting;
  final String? submitFailureMessage;

  bool get isValid =>
      dateError == null &&
      studentIdError == null &&
      purposeError == null &&
      draft.borrowDate != null &&
      draft.returnDate != null &&
      draft.studentId.trim().isNotEmpty &&
      draft.purpose.trim().isNotEmpty;

  LoanFormState copyWith({
    LoanRequestDraft? draft,
    LoanDateError? dateError,
    bool clearDateError = false,
    String? studentIdError,
    bool clearStudentIdError = false,
    String? purposeError,
    bool clearPurposeError = false,
    bool? isSubmitting,
    String? submitFailureMessage,
    bool clearSubmitFailureMessage = false,
  }) {
    return LoanFormState(
      draft: draft ?? this.draft,
      dateError: clearDateError ? null : (dateError ?? this.dateError),
      studentIdError: clearStudentIdError ? null : (studentIdError ?? this.studentIdError),
      purposeError: clearPurposeError ? null : (purposeError ?? this.purposeError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailureMessage: clearSubmitFailureMessage
          ? null
          : (submitFailureMessage ?? this.submitFailureMessage),
    );
  }
}

class LoanFormNotifier extends FamilyNotifier<LoanFormState, LoanFormKey> {
  @override
  LoanFormState build(LoanFormKey arg) {
    _restoreDraft(arg.deviceId);
    return LoanFormState(draft: LoanRequestDraft(deviceId: arg.deviceId));
  }

  Future<void> _restoreDraft(String deviceId) async {
    final repository = ref.read(loanRequestRepositoryProvider);
    final stored = await repository.loadDraft();
    if (stored != null && stored.deviceId == deviceId) {
      state = state.copyWith(draft: stored);
      _revalidateDates();
    }
  }

  void _persist() {
    ref.read(loanRequestRepositoryProvider).saveDraft(state.draft);
  }

  void setStudentId(String value) {
    state = state.copyWith(
      draft: state.draft.copyWith(studentId: value),
      studentIdError: value.trim().isEmpty ? 'Student ID is required' : null,
      clearStudentIdError: value.trim().isNotEmpty,
    );
    _persist();
  }

  void setPurpose(String value) {
    state = state.copyWith(
      draft: state.draft.copyWith(purpose: value),
      purposeError: value.trim().isEmpty ? 'Purpose is required' : null,
      clearPurposeError: value.trim().isNotEmpty,
    );
    _persist();
  }

  void setBorrowDate(DateTime date) {
    state = state.copyWith(draft: state.draft.copyWith(borrowDate: date));
    _revalidateDates();
    _persist();
  }

  void setReturnDate(DateTime date) {
    state = state.copyWith(draft: state.draft.copyWith(returnDate: date));
    _revalidateDates();
    _persist();
  }

  void _revalidateDates() {
    final borrow = state.draft.borrowDate;
    final returnD = state.draft.returnDate;
    if (borrow == null || returnD == null) {
      state = state.copyWith(clearDateError: true);
      return;
    }
    final error = ref.read(validateLoanPeriodProvider)(borrowDate: borrow, returnDate: returnD);
    state = error == null
        ? state.copyWith(clearDateError: true)
        : state.copyWith(dateError: error);
  }

  /// Guards rapid double-taps: a submit already in flight is a no-op, so
  /// exactly one POST is made no matter how many times the button is tapped.
  Future<Result<LoanRequestResult>?> submit() async {
    if (state.isSubmitting || !state.isValid) return null;
    state = state.copyWith(isSubmitting: true, clearSubmitFailureMessage: true);

    final payload = LoanRequestPayload(
      deviceId: arg.deviceId,
      studentId: state.draft.studentId.trim(),
      borrowDate: state.draft.borrowDate!,
      returnDate: state.draft.returnDate!,
      purpose: state.draft.purpose.trim(),
      deposit: arg.deposit,
    );

    final result = await ref.read(submitLoanRequestProvider).call(payload);
    if (result is Success<LoanRequestResult>) {
      await ref.read(loanRequestRepositoryProvider).clearDraft();
      state = state.copyWith(isSubmitting: false);
    } else if (result is Failed<LoanRequestResult>) {
      state = state.copyWith(isSubmitting: false, submitFailureMessage: result.failure.message);
    }
    return result;
  }
}

final loanFormProvider = NotifierProvider.family<LoanFormNotifier, LoanFormState, LoanFormKey>(
  LoanFormNotifier.new,
);
