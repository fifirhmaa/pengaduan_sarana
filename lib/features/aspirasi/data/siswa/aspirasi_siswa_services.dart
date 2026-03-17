import 'package:pocketbase/pocketbase.dart';

import '../../../../core/pocketbase_client.dart';

class AspirasiSiswaService {
  Future<void> buatKategoriDefault() async {
    final existing = await getKategori();
    if (existing.isNotEmpty) return;

    final defaultKategori = [
      {
        'kategori': 'Akademik',
        'ket_kategori': 'Aspirasi terkait pelajaran dan akademik',
      },
      {
        'kategori': 'Fasilitas',
        'ket_kategori': 'Aspirasi terkait sarana dan prasarana sekolah',
      },
      {
        'kategori': 'Non-Akademik',
        'ket_kategori': 'Aspirasi terkait kegiatan non-akademik',
      },
      {
        'kategori': 'Kesiswaan',
        'ket_kategori': 'Aspirasi terkait kebijakan kesiswaan',
      },
      {
        'kategori': 'Keamanan',
        'ket_kategori': 'Aspirasi terkait keamanan lingkungan sekolah',
      },
      {
        'kategori': 'Kebersihan',
        'ket_kategori': 'Aspirasi terkait kebersihan lingkungan sekolah',
      },
    ];

    for (var k in defaultKategori) {
      await pb.collection('kategori').create(body: k);
    }
  }

  // ================= CREATE ASPIRASI =================
  Future<void> createAspirasi({
    required String nis,
    required String lokasi,
    required String keterangan,
    required String kategoriId,
  }) async {
    final siswa = await getSiswaByNis(nis);
    if (siswa == null) throw Exception('Siswa tidak ditemukan');

    await getKategoriById(kategoriId);

    final body = {
      'nis': int.tryParse(nis) ?? 0,
      'lokasi': lokasi,
      'keterangan': keterangan,
      'status': 'Menunggu',
      'feedback': '',
      'kategori': kategoriId,
      'siswa': siswa.id,
    };

    await pb.collection('aspirasi').create(body: body);
  }

  // ================= DELETE ASPIRASI =================
  Future<void> deleteAspirasi(String aspirasiId) async {
    await pb.collection('aspirasi').delete(aspirasiId);
  }

  // ================= GET ASPIRASI =================
  Future<List<RecordModel>> getAspirasi({String? nis, String? siswaId}) async {
    String? filter;
    if (siswaId != null) {
      filter = "siswa = '$siswaId'";
    } else if (nis != null) {
      final siswa = await getSiswaByNis(nis);
      if (siswa == null) return [];
      filter = "siswa = '${siswa.id}'";
    }

    return await pb
        .collection('aspirasi')
        .getFullList(filter: filter, expand: 'kategori', sort: '-created');
  }

  // ================= GET KATEGORI =================
  Future<List<RecordModel>> getKategori() async {
    return await pb.collection('kategori').getFullList();
  }

  Future<RecordModel?> getKategoriById(String id) async {
    try {
      return await pb.collection('kategori').getOne(id);
    } catch (_) {
      throw Exception('Kategori tidak ditemukan');
    }
  }

  // ================= GET SISWA =================
  Future<RecordModel?> getSiswaById(String id) async {
    try {
      return await pb.collection('siswa').getOne(id);
    } catch (_) {
      return null;
    }
  }

  Future<RecordModel?> getSiswaByNis(String nis) async {
    try {
      return await pb.collection('siswa').getFirstListItem("nis = '$nis'");
    } catch (_) {
      return null;
    }
  }

  // ================= STATISTIK =================
  Future<Map<String, int>> getStatistik(String nis) async {
    final siswa = await getSiswaByNis(nis);
    if (siswa == null) return {};

    final aspirasi = await getAspirasi(siswaId: siswa.id);

    int menunggu = 0, proses = 0, selesai = 0;
    for (var a in aspirasi) {
      switch (a.data['status']) {
        case 'Menunggu':
          menunggu++;
          break;
        case 'Proses':
          proses++;
          break;
        case 'Selesai':
          selesai++;
          break;
      }
    }

    return {
      'total': aspirasi.length,
      'menunggu': menunggu,
      'proses': proses,
      'selesai': selesai,
    };
  }

  // ================= RESET =================
  Future<void> resetUntukTesting() async {
    final semua = await pb.collection('aspirasi').getFullList();
    for (var a in semua) {
      await pb.collection('aspirasi').delete(a.id);
    }
  }

  // ================= UPDATE STATUS =================
  Future<void> updateStatus({
    required String aspirasiId,
    required String status,
    String? feedback,
  }) async {
    final body = {'status': status};
    if (feedback != null) body['feedback'] = feedback;
    await pb.collection('aspirasi').update(aspirasiId, body: body);
  }
}
