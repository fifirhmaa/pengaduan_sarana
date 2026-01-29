import 'package:pocketbase/pocketbase.dart';
import '../../../../core/pocketbase_client.dart';

class AspirasiSiswaService {
  // ambil kategori
  Future<List<RecordModel>> getKategori() async {
    final res = await pb.collection('kategori').getFullList();
    return res;
  }

  // kirim aspirasi
  Future<void> createAspirasi({
    required int nis,
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

  // cek status aspirasi
  Future<List<RecordModel>> getAspirasiByNis(int nis) async {
    final res = await pb.collection('aspirasi').getFullList(
      filter: 'nis = $nis',
      expand: 'kategori',
      sort: '-created',
    );
    return res;
  }

  // cari siswa by NIS
  Future<RecordModel?> getSiswaByNis(int nis) async {
    final res = await pb.collection('siswa').getFullList(
      filter: 'nis = $nis',
    );
    if (res.isEmpty) return null;
    return res.first;
  }
}
