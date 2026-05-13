import 'package:flutter/material.dart';
import 'main_dashboard.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainDashboard(isReadOnly: true);
  }
}

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainDashboard(isReadOnly: false);
  }
}
