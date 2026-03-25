import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

void showDetailAspirasiModal(BuildContext context, RecordModel aspirasi) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => DetailAspirasiModal(aspirasi: aspirasi),
  );
}

class DetailAspirasiModal extends StatelessWidget {
  final RecordModel aspirasi;

  const DetailAspirasiModal({super.key, required this.aspirasi});

  @override
  Widget build(BuildContext context) {
    final status = aspirasi.data['status'] ?? '-';
    final lokasi = aspirasi.data['lokasi'] ?? '-';
    final deskripsi = aspirasi.data['keterangan'] ?? '-';
    final feedback = aspirasi.data['feedback']?.toString() ?? '';
    final nisn = aspirasi.data['nisn']?.toString() ?? '-';
    final kelas = aspirasi.data['kelas']?.toString() ?? '-';
    final tanggal = _formatDate(aspirasi.created);

    // Kategori dari expand
    String kategoriName = '-';
    final kategoriExpand = aspirasi.expand['kategori'] as List?;
    if (kategoriExpand != null && kategoriExpand.isNotEmpty) {
      kategoriName = kategoriExpand.first.data['kategori'] ?? '-';
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Aspirasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Informasi lengkap tentang aspirasi yang anda kirimkan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black54,
                      minimumSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status section
                    _SectionLabel(label: 'Status'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Kategori
                    _SectionLabel(label: 'Kategori'),
                    const SizedBox(height: 4),
                    _SectionValue(value: kategoriName),

                    const SizedBox(height: 16),

                    // Lokasi
                    _SectionLabel(label: 'Lokasi'),
                    const SizedBox(height: 4),
                    _SectionValue(value: lokasi),

                    const SizedBox(height: 16),

                    // Deskripsi
                    _SectionLabel(label: 'Deskripsi'),
                    const SizedBox(height: 4),
                    _SectionValue(value: deskripsi),

                    const SizedBox(height: 16),

                    // Waktu pengiriman
                    _SectionLabel(label: 'Waktu pengiriman'),
                    const SizedBox(height: 4),
                    _SectionValue(value: tanggal),

                    // Feedback section
                    if (feedback.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Feedback'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          feedback,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Proses':
        return Colors.orange;
      case 'Menunggu':
        return const Color(0xFF4FC3F7);
      default:
        return Colors.grey;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _SectionValue extends StatelessWidget {
  final String value;

  const _SectionValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[600]));
  }
}
