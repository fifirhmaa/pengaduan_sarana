import 'package:pocketbase/pocketbase.dart';
import 'package:ukk_pengaduan/core/pocketbase_client.dart';

class AspirasiSiswaService {

  Future<List<RecordModel>> getKategori() async {
    return await pb.collection('kategori').getFullList();
  }

  Future<void> createAspirasi({
    required String nis,
    required String kategoriId,
    required String lokasi,
    required String keterangan,
  }) async {
    await pb.collection('aspirasi').create(
      body: {
        'nis': nis,
        'kategori': kategoriId,
        'lokasi': lokasi,
        'keterangan': keterangan,
        'status': 'Menunggu',
      },
    );
  }

  Future<List<RecordModel>> getAspirasiByNis(String nis) async {
    return await pb.collection('aspirasi').getFullList(
      filter: 'nis = "$nis"',
      expand: 'kategori',
      sort: '-created',
    );
  }

  Future<RecordModel?> getSiswaByNis(String nis) async {
    final res = await pb.collection('siswa').getFullList(
      filter: 'nis = "$nis"',
    );
    if (res.isEmpty) return null;
    return res.first;
  }
}
