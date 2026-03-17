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
      appBar: AppBar(title: const Text('Input Aspirasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nisController,
                decoration: const InputDecoration(labelText: 'NIS'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'NIS wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: kategoriList.map((k) {
                  return DropdownMenuItem(
                    value: k.id,
                    child: Text(k.data['kategori'] ?? '-'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedKategori = v),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Keterangan wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
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
  void initState() {
    super.initState();
    loadKategori();
  }

  Future<void> loadKategori() async {
    try {
      final result = await service.getKategori();
      setState(() {
        kategoriList = result;
      });
    } catch (e) {
      debugPrint('Gagal load kategori: $e');
    }
  }

  Future<void> submit() async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aspirasi berhasil dikirim')),
      );

      // reset form
      _formKey.currentState!.reset();
      nisController.clear();
      lokasiController.clear();
      keteranganController.clear();
      setState(() => selectedKategori = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal kirim aspirasi: $e')));
    }

    setState(() => isLoading = false);
  }
}
