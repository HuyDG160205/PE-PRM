import 'dart:convert';

import 'package:pe/core/constants/storage_keys.dart';
import 'package:pe/core/storage/local_storage.dart';
import 'package:pe/features/loan_request/data/models/pending_loan_request_model.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_draft.dart';

abstract class LoanRequestLocalDataSource {
  Future<void> saveDraft(LoanRequestDraft draft);
  Future<LoanRequestDraft?> loadDraft();
  Future<void> clearDraft();

  Future<void> enqueuePending(PendingLoanRequestModel request);
  Future<List<PendingLoanRequestModel>> getPendingRequests();
  Future<void> markSubmitted(String idempotencyKey);
}

class LoanRequestLocalDataSourceImpl implements LoanRequestLocalDataSource {
  LoanRequestLocalDataSourceImpl(this._storage);

  final LocalStorage _storage;

  @override
  Future<void> saveDraft(LoanRequestDraft draft) async {
    await _storage.setString(StorageKeys.loanDraft, jsonEncode(draft.toJson()));
  }

  @override
  Future<LoanRequestDraft?> loadDraft() async {
    final raw = await _storage.getString(StorageKeys.loanDraft);
    if (raw == null) return null;
    return LoanRequestDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearDraft() async {
    await _storage.remove(StorageKeys.loanDraft);
  }

  @override
  Future<void> enqueuePending(PendingLoanRequestModel request) async {
    final all = await getPendingRequests();
    all.add(request);
    await _persist(all);
  }

  @override
  Future<List<PendingLoanRequestModel>> getPendingRequests() async {
    final raw = await _storage.getString(StorageKeys.pendingLoanRequests);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => PendingLoanRequestModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> markSubmitted(String idempotencyKey) async {
    final all = await getPendingRequests();
    final updated = all
        .map((r) => r.idempotencyKey == idempotencyKey ? r.copyWith(submitted: true) : r)
        // Drop entries once confirmed submitted; nothing else needs them.
        .where((r) => !r.submitted)
        .toList();
    await _persist(updated);
  }

  Future<void> _persist(List<PendingLoanRequestModel> requests) async {
    await _storage.setString(
      StorageKeys.pendingLoanRequests,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
  }
}
