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
  static const tealDark = Color(0xFF0F5C66);
  static const tealMid = Color(0xFF2A7C84);
  static const tealLight = Color(0xFF4A9BA5);
  static const bgLight = Color(0xFFE8F4F5);

  final service = AspirasiAdminService();
  List<RecordModel> list = [];
  List<RecordModel> filteredList = [];
  bool loading = true;
  String selectedStatus = 'Semua';
  String selectedKategori = 'Semua';
  String sortBy = 'Terbaru';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> kategoriList = [];

  int get menungguCount =>
      list.where((a) => a.data['status'] == 'Menunggu').length;
  int get prosesCount => list.where((a) => a.data['status'] == 'Proses').length;
  int get selesaiCount =>
      list.where((a) => a.data['status'] == 'Selesai').length;
  int get totalCount => list.length;

  void applyFilters() {
    List<RecordModel> result = List.from(list);

    if (selectedStatus != 'Semua') {
      result = result.where((a) => a.data['status'] == selectedStatus).toList();
    }

    if (selectedKategori != 'Semua') {
      result = result.where((a) {
        final kategori = a.expand['kategori']?.isNotEmpty == true
            ? a.expand['kategori']!.first.data['kategori']
            : '-';
        return kategori == selectedKategori;
      }).toList();
    }

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

    setState(() => filteredList = result);
  }

  @override
  Widget build(BuildContext context) {
    final hp = _hp(context);
    final isTablet = _isTablet(context);

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
              _buildHeader(context, hp),
              _buildSearchBar(context, hp),
              _buildFilterRow(context, hp),
              _buildStatCards(context, hp),
              _buildSortRow(context, hp),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : filteredList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: hp,
                          vertical: 8,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) =>
                            _buildCard(context, filteredList[i], isTablet),
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
    _searchController.dispose();
    super.dispose();
  }

  void extractKategoriList() {
    final Set<String> uniqueKategori = {};
    for (var a in list) {
      final kategori = a.expand['kategori']?.isNotEmpty == true
          ? a.expand['kategori']!.first.data['kategori']
          : null;
      if (kategori != null && kategori != '-') uniqueKategori.add(kategori);
    }
    setState(() => kategoriList = uniqueKategori.toList());
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Proses':
        return const Color(0xFFFFD254);
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
              backgroundColor: tealDark,
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
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
                _formField(
                  controller: namaCtrl,
                  label: 'Nama Kategori',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _formField(
                  controller: ketCtrl,
                  label: 'Keterangan',
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
                backgroundColor: tealDark,
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
        ),
      ),
    );
  }

  void openAddUser() {
    final formKey = GlobalKey<FormState>();
    final nisCtrl = TextEditingController();
    final kelasCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
                _formField(
                  controller: nisCtrl,
                  label: 'NIS',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'NIS wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _formField(
                  controller: kelasCtrl,
                  label: 'Kelas',
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
                backgroundColor: tealDark,
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
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, RecordModel a, bool isTablet) {
    final kategori = a.expand['kategori']?.isNotEmpty == true
        ? a.expand['kategori']!.first.data['kategori']
        : '-';
    final status = a.data['status'] ?? 'Menunggu';
    final nis = a.data['nis'] ?? '-';
    final lokasi = a.data['lokasi'] ?? '-';
    final keterangan = a.data['keterangan'] ?? '-';
    final feedback = a.data['feedback'];
    final tanggal = _formatDateShort(a.created);
    final statusColor = getStatusColor(status);
    final fs = _fontSize(context, 14.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
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
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              showDetailAspirasiAdmin(context, a, onUpdated: () => load()),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusChip(status, statusColor, context),
                    const SizedBox(width: 6),
                    Expanded(child: _categoryChip(kategori, context)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => showDetailAspirasiAdmin(
                        context,
                        a,
                        onUpdated: () => load(),
                      ),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: tealDark.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: tealDark.withOpacity(0.25)),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: tealDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  keterangan,
                  style: GoogleFonts.poppins(
                    fontSize: fs,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _metaItem(Icons.person_outline, 'NIS: $nis', context),
                    _metaItem(Icons.location_on_outlined, lokasi, context),
                    _metaItem(Icons.access_time_rounded, tanggal, context),
                  ],
                ),
                if (feedback != null && feedback.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: tealDark.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.feedback_outlined,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            feedback,
                            style: GoogleFonts.poppins(
                              fontSize: _fontSize(context, 12),
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada aspirasi',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, double hp) {
    final statuses = ['Semua', 'Menunggu', 'Proses', 'Selesai'];
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 10, hp, 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statuses.map((s) {
                  final isSelected = selectedStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedStatus = s);
                        applyFilters();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white38,
                          ),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.poppins(
                            fontSize: _fontSize(context, 11),
                            fontWeight: FontWeight.w600,
                            color: isSelected ? tealDark : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() => selectedKategori = val);
              applyFilters();
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => ['Semua', ...kategoriList]
                .map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(color: tealDark, fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white38),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedKategori == 'Semua' ? 'Kategori' : selectedKategori,
                    style: GoogleFonts.poppins(
                      fontSize: _fontSize(context, 11),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hp) {
    final isSmall = _isSmallPhone(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 14, hp, 10),
      child: Row(
        children: [
          Container(
            width: isSmall ? 34 : 40,
            height: isSmall ? 34 : 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white38),
            ),
            child: Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: isSmall ? 18 : 22,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASPIRASI',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: _fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Admin Panel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: _fontSize(context, 11),
                ),
              ),
            ],
          ),
          const Spacer(),
          _headerBtn(Icons.refresh_rounded, load, isSmall),
          const SizedBox(width: 6),
          _headerBtn(Icons.person_add_outlined, openAddUser, isSmall),
          const SizedBox(width: 6),
          _headerBtn(Icons.logout_rounded, logout, isSmall),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double hp) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 4),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white38),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: _fontSize(context, 13),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari NIS, lokasi, keterangan...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: _fontSize(context, 13),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() => searchQuery = val);
                  applyFilters();
                },
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => searchQuery = '');
                  applyFilters();
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.close, color: Colors.white60, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRow(BuildContext context, double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 10, hp, 6),
      child: Row(
        children: [
          Text(
            '${filteredList.length} aspirasi',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: _fontSize(context, 12),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Urutkan',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: _fontSize(context, 12),
            ),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() => sortBy = val);
              applyFilters();
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => ['Terbaru', 'Terlama', 'NIS']
                .map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(color: tealDark, fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white38),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sortBy,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: _fontSize(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, double hp) {
    final isSmall = _isSmallPhone(context);
    final stats = [
      _StatData(
        icon: Icons.list_alt_rounded,
        value: totalCount,
        label: 'Total',
        color: Colors.white,
      ),
      _StatData(
        icon: Icons.hourglass_empty_rounded,
        value: menungguCount,
        label: 'Menunggu',
        color: const Color(0xFF4FC3F7),
      ),
      _StatData(
        icon: Icons.settings_rounded,
        value: prosesCount,
        label: 'Proses',
        color: const Color(0xFFFFD254),
      ),
      _StatData(
        icon: Icons.check_circle_rounded,
        value: selesaiCount,
        label: 'Selesai',
        color: const Color(0xFF66BB6A),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 8, hp, 4),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < stats.length - 1 ? 6 : 0),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 4 : 6,
                  vertical: isSmall ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white38),
                ),
                child: Column(
                  children: [
                    Icon(s.icon, color: s.color, size: isSmall ? 16 : 18),
                    const SizedBox(height: 4),
                    Text(
                      '${s.value}',
                      style: GoogleFonts.poppins(
                        color: s.color,
                        fontSize: isSmall ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.label,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: isSmall ? 8 : 9,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _categoryChip(String label, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tealDark.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tealDark.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: tealDark,
          fontSize: _fontSize(context, 11),
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  double _fontSize(BuildContext context, double base) {
    if (_isSmallPhone(context)) return base - 1;
    if (_isTablet(context)) return base + 1;
    return base;
  }

  String _formatDateShort(dynamic date) {
    if (date == null) return '-';
    try {
      final dt = DateTime.parse(date.toString()).toLocal();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month]} · $hour:$minute';
    } catch (_) {
      return '-';
    }
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 13),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: tealDark, width: 1.5),
        ),
      ),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap, bool isSmall) {
    final size = isSmall ? 30.0 : 34.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white38),
        ),
        child: Icon(icon, color: Colors.white, size: isSmall ? 15 : 17),
      ),
    );
  }

  double _hp(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 600) return 24.0;
    if (w < 360) return 12.0;
    return 16.0;
  }

  bool _isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  Widget _metaItem(IconData icon, String text, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: _fontSize(context, 11),
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: _fontSize(context, 11),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}
