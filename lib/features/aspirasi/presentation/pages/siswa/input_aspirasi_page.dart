import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B5C6B),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sampaikan aspirasi atau keluhan anda untuk lingkungan sekolah yang lebih baik',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  Text('NISN', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: nisController,
                    decoration: InputDecoration(
                      hintText: 'Masukan NISN anda',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'NIS wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kategori',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedKategori,
                    decoration: InputDecoration(
                      hintText: 'Pilih kategori',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: kategoriList.map((k) {
                      return DropdownMenuItem(
                        value: k.id,
                        child: Text(k.data['kategori'] ?? '-'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedKategori = v),
                    validator: (v) =>
                        v == null ? 'Kategori wajib dipilih' : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Lokasi', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: lokasiController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Ruang 1, Kantin, dll',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: keteranganController,
                    decoration: InputDecoration(
                      hintText:
                          'Jelaskan aspirasi atau keluhan anda secara detail..',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B5C6B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                            backgroundColor: const Color(0xFF0B5C6B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Kirim Aspirasi',
                                      style: TextStyle(color: Colors.white),
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
