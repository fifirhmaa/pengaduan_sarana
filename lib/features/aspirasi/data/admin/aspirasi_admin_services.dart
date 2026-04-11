import 'package:pocketbase/pocketbase.dart';

import '../../../../core/pocketbase_client.dart';

class AspirasiAdminService {
  Future<void> createKategori({
    required String nama,
    required String ket,
  }) async {
    await pb
        .collection('kategori')
        .create(body: {'kategori': nama, 'ket_kategori': ket});
  }

  Future<void> createUser({required String nis, required String kelas}) async {
    await pb.collection('siswa').create(body: {'nis': nis, 'kelas': kelas});
  }

  Future<List<RecordModel>> getAllAspirasi() async {
    return await pb
        .collection('aspirasi')
        .getFullList(expand: 'kategori,siswa', sort: '-created');
  }

  void logout() {
    pb.authStore.clear();
  }

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
