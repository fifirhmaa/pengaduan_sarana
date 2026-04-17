import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../core/pocketbase_client.dart';
import '../../../../auth/landing/presentation/pages/landing_page.dart';
import '../../../data/admin/aspirasi_admin_services.dart';
import 'detail_aspirasi_admin.dart';

class AdminAspirasiPage extends StatefulWidget {
  const AdminAspirasiPage({super.key});

  @override
  State<AdminAspirasiPage> createState() => _AdminAspirasiPageState();
}

class _AdminAspirasiPageState extends State<AdminAspirasiPage>
    with SingleTickerProviderStateMixin {
  final service = AspirasiAdminService();
  List<RecordModel> list = [];
  List<RecordModel> filteredList = [];
  bool loading = true;

  // Filter variables
  String selectedStatus = 'Semua';
  String selectedKategori = 'Semua';
  String sortBy = 'Terbaru';
  String searchQuery = '';

  List<String> kategoriList = [];

  void applyFilters() {
    List<RecordModel> result = List.from(list);

    // Filter by status
    if (selectedStatus != 'Semua') {
      result = result.where((a) => a.data['status'] == selectedStatus).toList();
    }

    // Filter by kategori
    if (selectedKategori != 'Semua') {
      result = result.where((a) {
        final kategori = a.expand['kategori']?.isNotEmpty == true
            ? a.expand['kategori']!.first.data['kategori']
            : '-';
        return kategori == selectedKategori;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      result = result.where((a) {
        final nis = a.data['nis']?.toString().toLowerCase() ?? '';
        final lokasi = a.data['lokasi']?.toString().toLowerCase() ?? '';
        final keterangan = a.data['keterangan']?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return nis.contains(query) ||
            lokasi.contains(query) ||
            keterangan.contains(query);
      }).toList();
    }

    // Sort
    if (sortBy == 'Terbaru') {
      result.sort((a, b) => b.created.compareTo(a.created));
    } else if (sortBy == 'Terlama') {
      result.sort((a, b) => a.created.compareTo(b.created));
    } else if (sortBy == 'NIS') {
      result.sort((a, b) {
        final nisA = a.data['nis']?.toString() ?? '';
        final nisB = b.data['nis']?.toString() ?? '';
        return nisA.compareTo(nisB);
      });
    }

    setState(() {
      filteredList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isSmallPhone = screenSize.width < 360;

    final horizontalPadding = isTablet ? 24.0 : (isSmallPhone ? 12.0 : 16.0);

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
              _buildHeader(horizontalPadding, isTablet),
              _buildFilterNavbar(horizontalPadding),

              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : filteredList.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.white70),
                            SizedBox(height: 12),
                            Text(
                              'Tidak ada aspirasi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 16,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) {
                          final a = filteredList[i];
                          final kategori =
                              a.expand['kategori']?.isNotEmpty == true
                              ? a.expand['kategori']!.first.data['kategori']
                              : '-';
                          final status = a.data['status'] ?? 'Menunggu';
                          final nis = a.data['nis'] ?? '-';
                          final lokasi = a.data['lokasi'] ?? '-';
                          final keterangan = a.data['keterangan'] ?? '-';
                          final feedback = a.data['feedback'];
                          final tanggal = _formatDate(a.created);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                isTablet ? 20 : 16,
                              ),
                              border: Border.all(
                                color: getStatusColor(status).withOpacity(0.3),
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  isTablet ? 20 : 16,
                                ),
                                onTap: () => showDetailAspirasiAdmin(
                                  context,
                                  a,
                                  onUpdated: () => load(),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(status),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF0F5C66,
                                                ).withOpacity(0.3),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Color(0xFF0F5C66),
                                              ),
                                              onPressed: () =>
                                                  showDetailAspirasiAdmin(
                                                    context,
                                                    a,
                                                    onUpdated: () => load(),
                                                  ),
                                              constraints: const BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                              padding: EdgeInsets.zero,
                                              splashRadius: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
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
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 8,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'NIS: $nis',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.category,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                kategori,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
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
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
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
                                        ],
                                      ),
                                      if (feedback != null &&
                                          feedback.toString().isNotEmpty) ...[
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
                                                feedback,
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

  void extractKategoriList() {
    final Set<String> uniqueKategori = {};
    for (var a in list) {
      final kategori = a.expand['kategori']?.isNotEmpty == true
          ? a.expand['kategori']!.first.data['kategori']
          : null;
      if (kategori != null && kategori != '-') {
        uniqueKategori.add(kategori);
      }
    }
    setState(() {
      kategoriList = uniqueKategori.toList();
    });
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

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await service.getAllAspirasi();
    if (mounted) {
      setState(() {
        list = data;
        loading = false;
      });
      extractKategoriList();
      applyFilters();
    }
  }

  void logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin mau logout?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5C66),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              service.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Berhasil logout',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Tambah Kategori',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ketCtrl,
                      decoration: InputDecoration(
                        labelText: 'Keterangan',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5C66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                              SnackBar(
                                content: Text(
                                  'Kategori berhasil ditambahkan',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: $e',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          setStateDialog(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Tambah User Siswa',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nisCtrl,
                      decoration: InputDecoration(
                        labelText: 'NIS',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'NIS wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: kelasCtrl,
                      decoration: InputDecoration(
                        labelText: 'Kelas',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Kelas wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5C66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                              SnackBar(
                                content: Text(
                                  'User siswa berhasil ditambahkan',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.green,
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

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message,
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          setStateDialog(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterNavbar(double horizontalPadding) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      color: const Color(0xFF4A8B96),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedStatus = 'Semua';
                  selectedKategori = 'Semua';
                  sortBy = 'Terbaru';
                  searchQuery = '';
                  applyFilters();
                });
              },
              child: Text(
                'Semua',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Status Dropdown
          Expanded(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedStatus = value;
                  applyFilters();
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'Semua', child: Text('Semua')),
                const PopupMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                const PopupMenuItem(value: 'Proses', child: Text('Proses')),
                const PopupMenuItem(value: 'Selesai', child: Text('Selesai')),
              ],
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Kategori Dropdown
          Expanded(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedKategori = value;
                  applyFilters();
                });
              },
              itemBuilder: (BuildContext context) {
                final items = [
                  const PopupMenuItem(value: 'Semua', child: Text('Semua')),
                ];
                for (var kat in kategoriList) {
                  items.add(PopupMenuItem(value: kat, child: Text(kat)));
                }
                return items;
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kategori',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tanggal Dropdown
          Expanded(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  sortBy = value;
                  applyFilters();
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'Terbaru', child: Text('Terbaru')),
                const PopupMenuItem(value: 'Terlama', child: Text('Terlama')),
              ],
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tanggal',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // NISN Dropdown
          Expanded(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  sortBy = 'NIS';
                  applyFilters();
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'NIS', child: Text('Urutkan NIS')),
              ],
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NISN',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double horizontalPadding, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isTablet ? 20 : 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Admin - Aspirasi',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'Tambah Pengguna',
                    child: IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      onPressed: openAddUser,
                      tooltip: 'Tambah Pengguna Siswa',
                    ),
                  ),
                  Tooltip(
                    message: 'Tambah Kategori',
                    child: IconButton(
                      icon: const Icon(Icons.category, color: Colors.white),
                      onPressed: openAddKategori,
                      tooltip: 'Tambah Kategori Aspirasi',
                    ),
                  ),
                  Tooltip(
                    message: 'Logout',
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: logout,
                      tooltip: 'Keluar dari Sistem',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white54, height: 0),
      ],
    );
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
