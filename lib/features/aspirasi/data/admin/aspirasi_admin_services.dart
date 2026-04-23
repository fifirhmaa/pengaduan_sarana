import 'dart:typed_data';

import 'package:http/http.dart' as http;
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

  Future<void> deleteBuktiFoto({
    required String aspirasiId,
    required String filename,
  }) async {
    try {
      final aspirasi = await pb.collection('aspirasi').getOne(aspirasiId);
      final currentBuktiFoto = aspirasi.data['foto_bukti'] ?? [];

      List<String> updatedBuktiFoto = [];

      if (currentBuktiFoto is List) {
        updatedBuktiFoto = currentBuktiFoto
            .map((e) => e.toString())
            .where((f) => f != filename)
            .toList();
      } else if (currentBuktiFoto is String) {
        if (currentBuktiFoto != filename) {
          updatedBuktiFoto = [currentBuktiFoto];
        }
      }

      await pb
          .collection('aspirasi')
          .update(aspirasiId, body: {'foto_bukti': updatedBuktiFoto});
    } catch (e) {
      throw Exception('Gagal menghapus foto bukti: $e');
    }
  }

  Future<List<RecordModel>> getAllAspirasi() async {
    return await pb
        .collection('aspirasi')
        .getFullList(expand: 'kategori,siswa', sort: '-created');
  }

  String getBuktiFotoUrl(RecordModel aspirasi, String filename) {
    return pb.files.getUrl(aspirasi, filename).toString();
  }

  void logout() {
    pb.authStore.clear();
  }

  Future<void> updateStatus({
    required String aspirasiId,
    required String status,
    String? feedback,
    List<String>? buktiFoto,
  }) async {
    final data = <String, dynamic>{'status': status};

    if (feedback != null) {
      data['feedback'] = feedback;
    }

    if (buktiFoto != null && buktiFoto.isNotEmpty) {
      data['foto_bukti'] = buktiFoto;
    }

    await pb.collection('aspirasi').update(aspirasiId, body: data);
  }

  Future<String> uploadBuktiFoto({
    required String aspirasiId,
    required Uint8List fotoBytes,
    required String fileName,
  }) async {
    try {
      final record = await pb
          .collection('aspirasi')
          .update(
            aspirasiId,
            files: [
              http.MultipartFile.fromBytes(
                'foto_bukti',
                fotoBytes,
                filename: fileName,
              ),
            ],
          );

      final fotoData = record.data['foto_bukti'];
      if (fotoData is List && fotoData.isNotEmpty) {
        return fotoData.last.toString();
      } else if (fotoData is String && fotoData.isNotEmpty) {
        return fotoData;
      }

      throw Exception('Gagal mendapatkan nama file setelah upload');
    } catch (e) {
      throw Exception('Gagal upload foto bukti: $e');
    }
  }
}
