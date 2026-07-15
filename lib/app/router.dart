import 'package:flutter/material.dart';
import 'package:pe/app/route_names.dart';
import 'package:pe/features/equipment/presentation/pages/compare_page.dart';
import 'package:pe/features/equipment/presentation/pages/device_catalogue_page.dart';
import 'package:pe/features/equipment/presentation/pages/device_detail_page.dart';
import 'package:pe/features/loan_request/domain/entities/loan_request_result.dart';
import 'package:pe/features/loan_request/presentation/pages/loan_request_form_page.dart';
import 'package:pe/features/loan_request/presentation/pages/request_result_page.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.catalogue:
        return MaterialPageRoute(builder: (_) => const DeviceCataloguePage());
      case RouteNames.detail:
        final deviceId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => DeviceDetailPage(deviceId: deviceId));
      case RouteNames.loanForm:
        final deviceId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => LoanRequestFormPage(deviceId: deviceId));
      case RouteNames.requestResult:
        final result = settings.arguments as LoanRequestResult;
        return MaterialPageRoute(builder: (_) => RequestResultPage(result: result));
      case RouteNames.compare:
        return MaterialPageRoute(builder: (_) => const ComparePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('Unknown route: ${settings.name}'))),
        );
    }
  }
}
