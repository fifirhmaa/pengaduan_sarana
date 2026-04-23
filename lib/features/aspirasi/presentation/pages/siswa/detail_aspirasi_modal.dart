import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../core/pocketbase_client.dart';

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
    final tanggal = _formatDate(aspirasi.created);

    String kategoriName = '-';
    final kategoriExpand = aspirasi.expand['kategori'] as List?;
    if (kategoriExpand != null && kategoriExpand.isNotEmpty) {
      kategoriName = kategoriExpand.first.data['kategori'] ?? '-';
    }

    final fotoData = aspirasi.data['foto'];
    List<String> fotoFilenames = [];

    if (fotoData != null) {
      if (fotoData is List) {
        for (var foto in fotoData) {
          if (foto is String && foto.isNotEmpty) {
            fotoFilenames.add(foto);
          }
        }
      } else if (fotoData is String && fotoData.isNotEmpty) {
        fotoFilenames = [fotoData];
      }
    }

    final buktiFotoData = aspirasi.data['foto_bukti'];
    List<String> buktiFilenames = [];

    if (buktiFotoData != null) {
      if (buktiFotoData is List) {
        for (var foto in buktiFotoData) {
          if (foto is String && foto.isNotEmpty) {
            buktiFilenames.add(foto);
          }
        }
      } else if (buktiFotoData is String && buktiFotoData.isNotEmpty) {
        buktiFilenames = [buktiFotoData];
      }
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

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    _SectionLabel(label: 'Kategori'),
                    const SizedBox(height: 4),
                    _SectionValue(value: kategoriName),

                    const SizedBox(height: 16),

                    _SectionLabel(label: 'Lokasi'),
                    const SizedBox(height: 4),
                    _SectionValue(value: lokasi),

                    const SizedBox(height: 16),

                    _SectionLabel(label: 'Deskripsi'),
                    const SizedBox(height: 4),
                    _SectionValue(value: deskripsi),

                    const SizedBox(height: 16),

                    if (fotoFilenames.isNotEmpty) ...[
                      _SectionLabel(label: 'Foto Pendukung'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: fotoFilenames.length,
                          itemBuilder: (context, index) {
                            final fotoUrl = _getFotoUrl(fotoFilenames[index]);
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  _showFullImage(context, fotoUrl);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    fotoUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 200,
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Gagal memuat gambar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (buktiFilenames.isNotEmpty && status == 'Selesai') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 20,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Foto Bukti Pengerjaan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: buktiFilenames.length,
                                itemBuilder: (context, index) {
                                  final buktiUrl = _getFotoUrl(
                                    buktiFilenames[index],
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showFullImage(context, buktiUrl);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          buktiUrl,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.broken_image,
                                                        size: 48,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Gagal memuat gambar',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
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
                      const SizedBox(height: 16),
                    ],

                    _SectionLabel(label: 'Waktu pengiriman'),
                    const SizedBox(height: 4),
                    _SectionValue(value: tanggal),

                    if (feedback.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Feedback dari Admin'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.feedback,
                              size: 20,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
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

  String _getFotoUrl(String filename) {
    return pb.files.getUrl(aspirasi, filename).toString();
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

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black87,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Gagal memuat gambar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
