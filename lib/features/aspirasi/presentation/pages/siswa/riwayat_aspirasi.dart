import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isSmallPhone = screenSize.width < 360;

    final titleFontSize = isTablet ? 24.0 : 18.0;
    final subtitleFontSize = isTablet ? 16.0 : 14.0;
    final labelFontSize = isTablet ? 16.0 : 14.0;
    final backButtonFontSize = isTablet ? 18.0 : 16.0;

    final horizontalPadding = isTablet ? 32.0 : (isSmallPhone ? 16.0 : 24.0);
    final cardPadding = isTablet ? 24.0 : 20.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F5C66),
              Color(0xFF2A7C84),
              Color(0xFFE8F4F5),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Kembali',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: backButtonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Aspirasi',
                        style: GoogleFonts.poppins(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lihat semua aspirasi yang telah anda kirimkan',
                        style: GoogleFonts.poppins(
                          fontSize: subtitleFontSize,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nisController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Masukan NISN anda',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: labelFontSize - 2,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: labelFontSize - 1),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5C66),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            elevation: 1,
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
                              : Text(
                                  'Cek Riwayat',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: labelFontSize,
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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Divider(
                  color: Colors.white.withOpacity(0.4),
                  thickness: 1,
                ),
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
                            Icon(Icons.inbox, size: 64, color: Colors.white70),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada aspirasi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),
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
                                borderRadius: BorderRadius.circular(
                                  isTablet ? 20 : 16,
                                ),
                                border: Border.all(
                                  color: getStatusColor(
                                    status,
                                  ).withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    keterangan,
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                        style: GoogleFonts.poppins(
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (a.data['feedback'] != null &&
                                      a.data['feedback']
                                          .toString()
                                          .isNotEmpty) ...[
                                    const Divider(height: 16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                            ),
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
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('NISN wajib diisi', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengambil data: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
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
