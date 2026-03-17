import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../core/pocketbase_client.dart';
import '../../../../auth/landing/presentation/pages/landing_page.dart';
import '../../../data/admin/aspirasi_admin_services.dart';

class AdminAspirasiPage extends StatefulWidget {
  const AdminAspirasiPage({super.key});

  @override
  State<AdminAspirasiPage> createState() => _AdminAspirasiPageState();
}

class _AdminAspirasiPageState extends State<AdminAspirasiPage> {
  final service = AspirasiAdminService();
  List<RecordModel> list = [];
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Aspirasi'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: openAddUser,
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: openAddKategori,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (c, i) {
                final a = list[i];

                final kategori = a.expand['kategori']?.isNotEmpty == true
                    ? a.expand['kategori']!.first.data['kategori']
                    : '-';

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(a.data['keterangan'] ?? '-'),
                    subtitle: Text(
                      'NIS: ${a.data['nis']} • '
                      'Kategori: $kategori • '
                      'Status: ${a.data['status']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => openEdit(a),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await service.getAllAspirasi();
    setState(() {
      list = data;
      loading = false;
    });
  }

  // ================= LOGOUT =================
  void logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin mau logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              service.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Berhasil logout')));
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void openAddKategori() {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final ketCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah Kategori'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: ketCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setStateDialog(() => isLoading = true);

                          try {
                            await service.createKategori(
                              nama: namaCtrl.text,
                              ket: ketCtrl.text,
                            );

                            Navigator.pop(context);
                            load();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kategori berhasil ditambahkan'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }

                          setStateDialog(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= TAMBAH USER =================
  void openAddUser() {
    final formKey = GlobalKey<FormState>();
    final nisCtrl = TextEditingController();
    final kelasCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah User Siswa'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nisCtrl,
                      decoration: const InputDecoration(labelText: 'NIS'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'NIS wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: kelasCtrl,
                      decoration: const InputDecoration(labelText: 'Kelas'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Kelas wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setStateDialog(() => isLoading = true);

                          try {
                            await pb
                                .collection('siswa')
                                .create(
                                  body: {
                                    'nis': nisCtrl.text,
                                    'kelas': kelasCtrl.text,
                                  },
                                );

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'User siswa berhasil ditambahkan',
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(dialogContext);

                            String message = 'Gagal menambahkan user';

                            if (e is ClientException) {
                              final res = e.response;

                              if (res.containsKey('data') &&
                                  res['data'].toString().contains('nis')) {
                                message = 'NIS sudah terdaftar';
                              } else {
                                message = res['message'] ?? message;
                              }
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }

                          setStateDialog(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= EDIT =================
  void openEdit(RecordModel a) {
    final feedbackCtrl = TextEditingController(text: a.data['feedback'] ?? '');
    String status = a.data['status'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Aspirasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                DropdownMenuItem(value: 'Proses', child: Text('Proses')),
                DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
              ],
              onChanged: (v) => status = v!,
            ),
            TextField(
              controller: feedbackCtrl,
              decoration: const InputDecoration(labelText: 'Feedback'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.updateStatus(
                aspirasiId: a.id,
                status: status,
                feedback: feedbackCtrl.text,
              );

              Navigator.pop(context);
              load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
