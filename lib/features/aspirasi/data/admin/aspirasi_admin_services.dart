import 'package:pocketbase/pocketbase.dart';
import '../../../../core/pocketbase_client.dart';

class AspirasiAdminService {
  // ambil semua aspirasi
  Future<List<RecordModel>> getAllAspirasi() async {
    final res = await pb.collection('aspirasi').getFullList(
      expand: 'kategori,siswa',
      sort: '-created',
    );
    return res;
  }

  // update status
  Future<void> updateStatus({
    required String aspirasiId,
    required String status,
    String? feedback,
  }) async {
    await pb.collection('aspirasi').update(
      aspirasiId,
      body: {
        'status': status,
        'feedback': feedback,
      },
    );
  }
}
