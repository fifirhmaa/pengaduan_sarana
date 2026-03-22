import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/siswa/aspirasi_siswa_services.dart';
import 'detail_aspirasi_modal.dart';

class RiwayatAspirasi extends StatefulWidget {
  const RiwayatAspirasi({super.key});

  @override
  State<RiwayatAspirasi> createState() => _RiwayatAspirasiState();
}

class _RiwayatAspirasiState extends State<RiwayatAspirasi> {
  final nisController = TextEditingController();
  final service = AspirasiSiswaService();

  List<RecordModel> list = [];
  bool loading = false;
  bool hasCeked = false;
  String? _currentNis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF155C6B),
      body: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Kembali',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat Aspirasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lihat semua aspirasi yang telah anda kirimkan',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nisController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Masukan NISN anda',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF155C6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: loading ? null : _cekStatus,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Cek Riwayat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: Colors.white.withOpacity(0.4), thickness: 1),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: !hasCeked
                ? const SizedBox()
                : loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : list.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.white54),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada aspirasi',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final a = list[i];
                      final status = a.data['status'] ?? '-';
                      final lokasi = a.data['lokasi'] ?? '-';
                      final keterangan = a.data['keterangan'] ?? '-';
                      final tanggal = _formatDate(a.created);
                      return GestureDetector(
                        onTap: () => showDetailAspirasiModal(context, a),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: getStatusColor(status).withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                keterangan,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    lokasi,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tanggal,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              if (a.data['feedback'] != null &&
                                  a.data['feedback'].toString().isNotEmpty) ...[
                                const Divider(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.feedback,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        a.data['feedback'],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_currentNis != null) {
      service.unsubscribe();
    }
    nisController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Proses':
        return const Color.fromARGB(255, 255, 210, 84);
      case 'Menunggu':
        return const Color(0xFF4FC3F7);
      default:
        return Colors.grey;
    }
  }

  Future<void> _cekStatus() async {
    final nis = nisController.text.trim();
    if (nis.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('NISN wajib diisi')));
      return;
    }

    if (_currentNis != null) {
      await service.unsubscribe();
    }

    setState(() {
      loading = true;
      hasCeked = true;
      list = [];
      _currentNis = nis;
    });

    try {
      final data = await service.getAspirasi(nis: nis);
      if (!mounted) return;
      setState(() => list = data);
      await service.subscribeAspirasi(
        nis: nis,
        onUpdate: (updatedRecord) {
          if (!mounted) return;
          setState(() {
            final idx = list.indexWhere((e) => e.id == updatedRecord.id);
            if (idx != -1) {
              list[idx] = updatedRecord;
            } else {
              list.insert(0, updatedRecord);
            }
          });
        },
        onDelete: (deletedId) {
          if (!mounted) return;
          setState(() => list.removeWhere((e) => e.id == deletedId));
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dt = DateTime.parse(date.toString()).toLocal();
      const months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month]} ${dt.year} | $hour.$minute';
    } catch (_) {
      return '-';
    }
  }
}
