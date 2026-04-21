import 'dart:html' as html;
import 'dart:typed_data';

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

  Uint8List? fotoBytes;
  String? fileName;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isDesktop = screenSize.width >= 1200;
    final isSmallPhone = screenSize.width < 360;

    final titleFontSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 20.0);
    final subtitleFontSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);
    final labelFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final inputFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : 13.0);
    final hintFontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);

    final outerHorizontalPadding = isDesktop
        ? 32.0
        : (isTablet ? 16.0 : (isSmallPhone ? 6.0 : 8.0));

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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 20 : 16,
              horizontal: outerHorizontalPadding,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                border: Border.all(
                  color: const Color(0xFF0F5C66).withOpacity(0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                        hintStyle: GoogleFonts.poppins(fontSize: hintFontSize),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 16 : 14,
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: inputFontSize),
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
                        hintStyle: GoogleFonts.poppins(fontSize: hintFontSize),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 16 : 14,
                        ),
                      ),
                      items: kategoriList.map((k) {
                        return DropdownMenuItem(
                          value: k.id,
                          child: Text(
                            k.data['kategori'] ?? '-',
                            style: GoogleFonts.poppins(fontSize: inputFontSize),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedKategori = v),
                      validator: (v) =>
                          v == null ? 'Kategori wajib dipilih' : null,
                      style: GoogleFonts.poppins(fontSize: inputFontSize),
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
                        hintStyle: GoogleFonts.poppins(fontSize: hintFontSize),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 16 : 14,
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: inputFontSize),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
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
                        hintStyle: GoogleFonts.poppins(fontSize: hintFontSize),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 16 : 14,
                        ),
                      ),
                      maxLines: isDesktop ? 5 : 4,
                      style: GoogleFonts.poppins(fontSize: inputFontSize),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Deskripsi wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Foto Bukti',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: labelFontSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (fotoBytes != null && fileName != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.memory(
                                    fotoBytes!,
                                    height: isDesktop
                                        ? 250
                                        : (isTablet ? 200 : 180),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          fotoBytes = null;
                                          fileName = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (fotoBytes == null)
                            InkWell(
                              onTap: _pickImage,
                              child: Container(
                                height: isDesktop
                                    ? 180
                                    : (isTablet ? 150 : 130),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload,
                                        size: isDesktop ? 48 : 40,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Klik untuk upload foto',
                                        style: GoogleFonts.poppins(
                                          fontSize: hintFontSize,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Format: JPG, PNG (Max 5MB)',
                                        style: GoogleFonts.poppins(
                                          fontSize: hintFontSize - 2,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (fileName != null && fotoBytes != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                fileName!,
                                style: GoogleFonts.poppins(
                                  fontSize: hintFontSize,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
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
                            onPressed: isLoading ? null : _submit,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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

  Future<void> _pickImage() async {
    try {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/jpeg,image/png,image/jpg';
      uploadInput.multiple = false;

      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];

          if (file.size > 5 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file maksimal 5MB'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final fileType = file.type;
          if (!fileType.startsWith('image/')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hanya file gambar yang diperbolehkan'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((event) {
            setState(() {
              fotoBytes = reader.result as Uint8List?;
              fileName = file.name;
            });
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
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
        fotoBytes: fotoBytes,
        fileName: fileName,
      );

      _formKey.currentState!.reset();
      nisController.clear();
      lokasiController.clear();
      keteranganController.clear();
      setState(() {
        selectedKategori = null;
        fotoBytes = null;
        fileName = null;
      });

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
