import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/pocketbase_client.dart';

class AspirasiSiswaService {
  Future<void> buatKategoriDefault() async {
    try {
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
    } catch (e) {
      throw Exception('Gagal membuat kategori default: $e');
    }
  }

  Future<RecordModel> createAspirasi({
    required String nis,
    required String lokasi,
    required String keterangan,
    required String kategoriId,
    Uint8List? fotoBytes,
    String? fileName,
  }) async {
    try {
      if (nis.isEmpty) throw Exception('NIS tidak boleh kosong');
      if (lokasi.isEmpty) throw Exception('Lokasi tidak boleh kosong');
      if (keterangan.isEmpty) throw Exception('Keterangan tidak boleh kosong');
      if (kategoriId.isEmpty) throw Exception('Kategori tidak boleh kosong');

      final siswa = await getSiswaByNis(nis);
      if (siswa == null)
        throw Exception('Siswa dengan NIS $nis tidak ditemukan');

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

      if (fotoBytes != null && fileName != null && fotoBytes.isNotEmpty) {
        if (!isValidFileSize(fotoBytes, maxSizeMB: 5)) {
          throw Exception('Ukuran file maksimal 5MB');
        }

        if (!isValidImageType(fileName)) {
          throw Exception('Format file harus JPG, JPEG, PNG, atau WEBP');
        }

        final file = http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: fileName,
        );
        final result = await pb
            .collection('aspirasi')
            .create(body: body, files: [file]);
        return result;
      }

      final record = await pb.collection('aspirasi').create(body: body);
      return record;
    } catch (e) {
      throw Exception('Gagal membuat aspirasi: $e');
    }
  }

  Future<RecordModel> createAspirasiWithMultipleFotos({
    required String nis,
    required String lokasi,
    required String keterangan,
    required String kategoriId,
    required List<({Uint8List bytes, String name})> fotos,
  }) async {
    try {
      if (nis.isEmpty) throw Exception('NIS tidak boleh kosong');
      if (lokasi.isEmpty) throw Exception('Lokasi tidak boleh kosong');
      if (keterangan.isEmpty) throw Exception('Keterangan tidak boleh kosong');
      if (kategoriId.isEmpty) throw Exception('Kategori tidak boleh kosong');

      final siswa = await getSiswaByNis(nis);
      if (siswa == null)
        throw Exception('Siswa dengan NIS $nis tidak ditemukan');

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

      if (fotos.isNotEmpty) {
        if (fotos.length > 5) {
          throw Exception('Maksimal upload 5 foto');
        }

        final files = <http.MultipartFile>[];
        for (var i = 0; i < fotos.length; i++) {
          final foto = fotos[i];
          if (!isValidFileSize(foto.bytes, maxSizeMB: 5)) {
            throw Exception('Ukuran file ${foto.name} melebihi 5MB');
          }

          if (!isValidImageType(foto.name)) {
            throw Exception('Format file ${foto.name} tidak didukung');
          }

          files.add(
            http.MultipartFile.fromBytes(
              'foto',
              foto.bytes,
              filename: foto.name,
            ),
          );
        }

        final result = await pb
            .collection('aspirasi')
            .create(body: body, files: files);
        return result;
      }

      final record = await pb.collection('aspirasi').create(body: body);
      return record;
    } catch (e) {
      throw Exception('Gagal membuat aspirasi: $e');
    }
  }

  Future<void> deleteAspirasi(String aspirasiId) async {
    try {
      if (aspirasiId.isEmpty) throw Exception('ID aspirasi tidak boleh kosong');
      await pb.collection('aspirasi').delete(aspirasiId);
    } catch (e) {
      throw Exception('Gagal menghapus aspirasi: $e');
    }
  }

  Future<void> deleteFoto(String aspirasiId, {int? index}) async {
    try {
      final aspirasi = await pb.collection('aspirasi').getOne(aspirasiId);
      final currentFoto = aspirasi.data['foto'];

      if (currentFoto == null) {
        throw Exception('Tidak ada foto untuk dihapus');
      }

      if (currentFoto is List && index != null) {
        final updatedFotos = List.from(currentFoto);
        if (index < updatedFotos.length) {
          updatedFotos.removeAt(index);
          await pb
              .collection('aspirasi')
              .update(
                aspirasiId,
                body: {'foto': updatedFotos.isEmpty ? null : updatedFotos},
              );
        } else {
          throw Exception('Index foto tidak valid');
        }
      } else {
        await pb
            .collection('aspirasi')
            .update(aspirasiId, body: {'foto': null});
      }
    } catch (e) {
      throw Exception('Gagal menghapus foto: $e');
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  List<String> getAllFotoUrls(RecordModel aspirasi) {
    try {
      final fotoData = aspirasi.data['foto'];
      if (fotoData == null) return [];

      List<String> fotoFiles = [];
      if (fotoData is List) {
        fotoFiles = List<String>.from(fotoData);
      } else if (fotoData is String && fotoData.isNotEmpty) {
        fotoFiles = [fotoData];
      } else {
        return [];
      }

      return fotoFiles
          .map((file) => pb.files.getUrl(aspirasi, file).toString())
          .toList();
    } catch (e) {
      print('Error getting all foto URLs: $e');
      return [];
    }
  }

  Future<List<RecordModel>> getAspirasi({String? nis, String? siswaId}) async {
    try {
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
    } catch (e) {
      throw Exception('Gagal mengambil data aspirasi: $e');
    }
  }

  Future<RecordModel?> getAspirasiById(String id) async {
    try {
      return await pb.collection('aspirasi').getOne(id, expand: 'kategori');
    } catch (e) {
      return null;
    }
  }

  String? getFotoUrl(RecordModel aspirasi, {int index = 0}) {
    try {
      final fotoData = aspirasi.data['foto'];
      if (fotoData == null) return null;

      List<String> fotoFiles = [];
      if (fotoData is List) {
        fotoFiles = List<String>.from(fotoData);
      } else if (fotoData is String && fotoData.isNotEmpty) {
        fotoFiles = [fotoData];
      } else {
        return null;
      }

      if (fotoFiles.isEmpty || index >= fotoFiles.length) return null;

      return pb.files.getUrl(aspirasi, fotoFiles[index]).toString();
    } catch (e) {
      print('Error getting foto URL: $e');
      return null;
    }
  }

  Future<List<RecordModel>> getKategori() async {
    try {
      return await pb.collection('kategori').getFullList();
    } catch (e) {
      throw Exception('Gagal mengambil data kategori: $e');
    }
  }

  Future<RecordModel> getKategoriById(String id) async {
    try {
      return await pb.collection('kategori').getOne(id);
    } catch (e) {
      throw Exception('Kategori tidak ditemukan');
    }
  }

  Future<RecordModel?> getSiswaById(String id) async {
    try {
      return await pb.collection('siswa').getOne(id);
    } catch (e) {
      return null;
    }
  }

  Future<RecordModel?> getSiswaByNis(String nis) async {
    try {
      return await pb.collection('siswa').getFirstListItem("nis = '$nis'");
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, int>> getStatistik(String nis) async {
    try {
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
    } catch (e) {
      throw Exception('Gagal mengambil statistik: $e');
    }
  }

  bool isValidFileSize(Uint8List bytes, {int maxSizeMB = 5}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return bytes.lengthInBytes <= maxSizeBytes;
  }

  bool isValidImageType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  Future<void> resetUntukTesting() async {
    try {
      final semua = await pb.collection('aspirasi').getFullList();
      for (var a in semua) {
        await pb.collection('aspirasi').delete(a.id);
      }
    } catch (e) {
      throw Exception('Gagal reset data: $e');
    }
  }

  Future<void> subscribeAspirasi({
    required String nis,
    required Function(RecordModel) onUpdate,
    required Function(String) onDelete,
  }) async {
    try {
      await pb.collection('aspirasi').subscribe('*', (e) {
        final recordNis = e.record?.data['nis']?.toString();
        if (recordNis != nis) return;

        if (e.action == 'delete') {
          onDelete(e.record!.id);
        } else if (e.record != null) {
          onUpdate(e.record!);
        }
      }, filter: 'nis = ${int.tryParse(nis) ?? 0}');
    } catch (e) {
      throw Exception('Gagal subscribe aspirasi: $e');
    }
  }

  Future<void> unsubscribe() async {
    try {
      await pb.collection('aspirasi').unsubscribe('*');
    } catch (e) {
      throw Exception('Gagal unsubscribe aspirasi: $e');
    }
  }

  Future<void> updateFoto({
    required String aspirasiId,
    required Uint8List fotoBytes,
    required String fileName,
    bool replace = true,
  }) async {
    try {
      if (!isValidFileSize(fotoBytes, maxSizeMB: 5)) {
        throw Exception('Ukuran file maksimal 5MB');
      }

      if (!isValidImageType(fileName)) {
        throw Exception('Format file harus JPG, JPEG, PNG, atau WEBP');
      }

      final file = http.MultipartFile.fromBytes(
        'foto',
        fotoBytes,
        filename: fileName,
      );

      if (replace) {
        await pb
            .collection('aspirasi')
            .update(aspirasiId, body: {}, files: [file]);
      } else {
        throw Exception(
          'Untuk multiple files, gunakan createAspirasiWithMultipleFotos',
        );
      }
    } catch (e) {
      throw Exception('Gagal mengupdate foto: $e');
    }
  }

  Future<void> updateStatus({
    required String aspirasiId,
    required String status,
    String? feedback,
  }) async {
    try {
      final body = {'status': status};
      if (feedback != null && feedback.isNotEmpty) body['feedback'] = feedback;
      await pb.collection('aspirasi').update(aspirasiId, body: body);
    } catch (e) {
      throw Exception('Gagal mengupdate status: $e');
    }
  }
}
