import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/siswa/aspirasi_siswa_services.dart';
import 'success_aspirasi_page.dart';

class InputAspirasiPage extends StatefulWidget {
  const InputAspirasiPage({super.key});

  @override
  State<InputAspirasiPage> createState() => _InputAspirasiPageState();
}

class _InputAspirasiPageState extends State<InputAspirasiPage> {
  final _formKey = GlobalKey<FormState>();
  final service = AspirasiSiswaService();

  final nisController = TextEditingController();
  final lokasiController = TextEditingController();
  final keteranganController = TextEditingController();

  List<RecordModel> kategoriList = [];
  String? selectedKategori;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isSmallPhone = screenSize.width < 360;

    // Responsive container width
    final containerWidth = isTablet ? 500.0 : (isSmallPhone ? 320.0 : 350.0);

    // Responsive padding
    final verticalPadding = isTablet ? 48.0 : 32.0;
    final horizontalPadding = isTablet ? 32.0 : 24.0;

    // Responsive font sizes
    final titleFontSize = isTablet ? 28.0 : 20.0;
    final subtitleFontSize = isTablet ? 16.0 : 14.0;
    final labelFontSize = isTablet ? 16.0 : 14.0;

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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 40 : 20,
                horizontal: isTablet ? 32 : 16,
              ),
              child: Container(
                width: containerWidth,
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Aspirasi Siswa',
                        style: GoogleFonts.poppins(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sampaikan aspirasi atau keluhan anda untuk lingkungan sekolah yang lebih baik',
                        style: GoogleFonts.poppins(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'NISN',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: labelFontSize,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: nisController,
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
                        validator: (v) =>
                            v == null || v.isEmpty ? 'NIS wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kategori',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: labelFontSize,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: selectedKategori,
                        decoration: InputDecoration(
                          hintText: 'Pilih kategori',
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
                        items: kategoriList.map((k) {
                          return DropdownMenuItem(
                            value: k.id,
                            child: Text(
                              k.data['kategori'] ?? '-',
                              style: GoogleFonts.poppins(
                                fontSize: labelFontSize - 1,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedKategori = v),
                        validator: (v) =>
                            v == null ? 'Kategori wajib dipilih' : null,
                        style: GoogleFonts.poppins(fontSize: labelFontSize - 1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lokasi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: labelFontSize,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: lokasiController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Ruang 1, Kantin, dll',
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
                        validator: (v) => v == null || v.isEmpty
                            ? 'Lokasi wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Deskripsi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: labelFontSize,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: keteranganController,
                        decoration: InputDecoration(
                          hintText:
                              'Jelaskan aspirasi atau keluhan anda secara detail..',
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
                        maxLines: 4,
                        style: GoogleFonts.poppins(fontSize: labelFontSize - 1),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Deskripsi wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F5C66),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 18 : 16,
                                ),
                                elevation: 1,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F5C66),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 18 : 16,
                                ),
                                elevation: 1,
                              ),
                              onPressed: _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Kirim Aspirasi',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: labelFontSize,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadKategori();
  }

  Future<void> loadKategori() async {
    try {
      final result = await service.getKategori();
      if (!mounted) return;
      setState(() {
        kategoriList = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessAspirasiModal() {
    showSuccessAspirasiModal(context);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedKategori == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih kategori')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await service.createAspirasi(
        nis: nisController.text.trim(),
        lokasi: lokasiController.text.trim(),
        keterangan: keteranganController.text.trim(),
        kategoriId: selectedKategori!,
      );

      // Reset form
      _formKey.currentState!.reset();
      nisController.clear();
      lokasiController.clear();
      keteranganController.clear();
      setState(() => selectedKategori = null);

      // Show success dialog
      _showSuccessAspirasiModal();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal kirim aspirasi: $e')));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }
}
