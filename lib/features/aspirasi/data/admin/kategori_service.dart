import 'package:pocketbase/pocketbase.dart';

import '../../../../core/pocketbase_client.dart';

class KategoriService {
  Future<void> createKategori({
    required String nama,
    required String keterangan,
  }) async {
    await pb
        .collection('kategori')
        .create(body: {'kategori': nama, 'ket_kategori': keterangan});
  }

  Future<List<RecordModel>> getAllKategori() async {
    return await pb.collection('kategori').getFullList();
  }
}
