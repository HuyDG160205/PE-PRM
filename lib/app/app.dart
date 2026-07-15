import 'package:flutter/material.dart';
import 'package:pe/app/route_names.dart';
import 'package:pe/app/router.dart';
import 'package:pe/app/theme.dart';

class CampusEquipmentLoanApp extends StatelessWidget {
  const CampusEquipmentLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Equipment Loan',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: RouteNames.catalogue,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
