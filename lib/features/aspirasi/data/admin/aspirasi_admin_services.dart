import 'package:pocketbase/pocketbase.dart';

import '../../../../core/pocketbase_client.dart';

class AspirasiAdminService {
  // TAMBAH KATEGORI
  Future<void> createKategori({
    required String nama,
    required String ket,
  }) async {
    await pb
        .collection('kategori')
        .create(body: {'kategori': nama, 'ket_kategori': ket});
  }

  // TAMBAH SISWA
  Future<void> createUser({required String nis, required String kelas}) async {
    await pb.collection('siswa').create(body: {'nis': nis, 'kelas': kelas});
  }

  // GET ALL
  Future<List<RecordModel>> getAllAspirasi() async {
    return await pb
        .collection('aspirasi')
        .getFullList(expand: 'kategori,siswa', sort: '-created');
  }

  // LOGOUT
  void logout() {
    pb.authStore.clear();
  }

  // UPDATE STATUS
  Future<void> updateStatus({
    required String aspirasiId,
    required String status,
    String? feedback,
  }) async {
    await pb
        .collection('aspirasi')
        .update(aspirasiId, body: {'status': status, 'feedback': feedback});
  }
}
