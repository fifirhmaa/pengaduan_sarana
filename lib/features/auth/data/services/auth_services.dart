import '../../../../core/pocketbase_client.dart';

class AuthService {
  bool get isLoggedIn => pb.authStore.isValid;

  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    final res = await pb.collection('users').authWithPassword(email, password);

    if (res.record?.data['role'] != 'admin') {
      pb.authStore.clear();
      throw Exception('Bukan akun admin');
    }
  }

  void logout() {
    pb.authStore.clear();
  }
}
