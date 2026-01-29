import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/siswa/aspirasi_siswa_services.dart';

class InputAspirasiPage extends StatefulWidget {
  const InputAspirasiPage({super.key});

  @override
  State<InputAspirasiPage> createState() => _InputAspirasiPageState();
}

class _InputAspirasiPageState extends State<InputAspirasiPage> {
  final _formKey = GlobalKey<FormState>();

  final aspirasiService = AspirasiSiswaService();

  final nisController = TextEditingController();
  final lokasiController = TextEditingController();
  final keteranganController = TextEditingController();

  bool isLoading = false;

  // 🔹 KATEGORI
  List<RecordModel> kategoriList = [];
  String? selectedKategori;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Aspirasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nisController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'NIS'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'NIS wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // 🔽 DROPDOWN KATEGORI
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: kategoriList.map((k) {
                  return DropdownMenuItem<String>(
                    value: k.id,
                    child: Text(k.data['kategori']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKategori = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Lokasi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Keterangan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : submitAspirasi,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Kirim Aspirasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nisController.dispose();
    lokasiController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadKategori();
  }

  Future<void> loadKategori() async {
    try {
      final result = await aspirasiService.getKategori();
      setState(() {
        kategoriList = result.cast<RecordModel>();
      });
    } catch (e) {
      debugPrint('Gagal load kategori: $e');
    }
  }

  Future<void> submitAspirasi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 1. cari siswa
      final siswa = await aspirasiService.getSiswaByNis(
        int.parse(nisController.text),
      );

      if (siswa == null) {
        throw 'Siswa dengan NIS tersebut tidak ditemukan';
      }

      // 2. kirim aspirasi
      await aspirasiService.createAspirasi(
        nis: int.parse(nisController.text),
        kategoriId: selectedKategori!,
        lokasi: lokasiController.text,
        keterangan: keteranganController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aspirasi berhasil dikirim')),
      );

      nisController.clear();
      lokasiController.clear();
      keteranganController.clear();
      selectedKategori = null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }
}
