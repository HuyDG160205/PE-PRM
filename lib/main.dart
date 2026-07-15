import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pe/app/app.dart';
import 'package:pe/app/providers.dart';
import 'package:pe/features/loan_request/presentation/providers/loan_request_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  // Fire-and-forget: send any loan requests queued while offline now that
  // the app has network access again.
  unawaited(container.read(retryPendingRequestsProvider).call());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CampusEquipmentLoanApp(),
    ),
  );
}
