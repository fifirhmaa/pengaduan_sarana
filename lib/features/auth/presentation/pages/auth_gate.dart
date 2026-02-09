import 'package:flutter/material.dart';

import '../../../../core/pocketbase_client.dart';
import '../../../aspirasi/presentation/pages/admin/admin_aspirasi_page.dart';
import '../../landing/presentation/pages/landing_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = pb.authStore.model;

    if (user == null) {
      return const LandingPage();
    }

    final role = user.data['role'];

    if (role == 'admin') {
      return const AdminAspirasiPage();
    }

    return const LandingPage();
  }
}
