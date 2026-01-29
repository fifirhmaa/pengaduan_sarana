import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../core/pocketbase_client.dart';
import '../../../aspirasi/presentation/pages/admin/admin_aspirasi_page.dart';
import '../../../aspirasi/presentation/pages/siswa/input_aspirasi_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final RecordModel? user = pb.authStore.model;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Belum login')),
      );
    }

    final role = user.data['role'];

    if (role == 'admin') {
      return const AdminAspirasiPage();
    } else {
      return const InputAspirasiPage();
    }
  }
}
