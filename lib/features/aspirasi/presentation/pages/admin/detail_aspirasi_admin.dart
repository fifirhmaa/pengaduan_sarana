import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../core/pocketbase_client.dart';
import '../../../data/admin/aspirasi_admin_services.dart';

void showDetailAspirasiAdmin(
  BuildContext context,
  RecordModel aspirasi, {
  VoidCallback? onUpdated,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        DetailAspirasiAdminModal(aspirasi: aspirasi, onUpdated: onUpdated),
  );
}

class DetailAspirasiAdminModal extends StatefulWidget {
  final RecordModel aspirasi;
  final VoidCallback? onUpdated;

  const DetailAspirasiAdminModal({
    super.key,
    required this.aspirasi,
    this.onUpdated,
  });

  @override
  State<DetailAspirasiAdminModal> createState() =>
      _DetailAspirasiAdminModalState();
}

class _DetailAspirasiAdminModalState extends State<DetailAspirasiAdminModal> {
  final service = AspirasiAdminService();
  late String status;
  late TextEditingController feedbackController;
  bool isUpdating = false;

  Uint8List? buktiBytes;
  String? buktiFileName;
  List<String> existingBuktiFilenames = [];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isSmallPhone = screenSize.width < 360;
    final isStatusSelesai = status == 'Selesai';

    final lokasi = widget.aspirasi.data['lokasi'] ?? '-';
    final deskripsi = widget.aspirasi.data['keterangan'] ?? '-';
    final nis = widget.aspirasi.data['nis']?.toString() ?? '-';
    final tanggal = _formatDate(widget.aspirasi.created);

    String kategoriName = '-';
    final kategoriExpand = widget.aspirasi.expand['kategori'] as List?;
    if (kategoriExpand != null && kategoriExpand.isNotEmpty) {
      kategoriName = kategoriExpand.first.data['kategori'] ?? '-';
    }

    final fotoData = widget.aspirasi.data['foto'];
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

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24 : 20,
                isTablet ? 24 : 20,
                12,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Aspirasi',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Informasi lengkap tentang aspirasi siswa',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 13,
                            color: Colors.grey[500],
                            height: 1.4,
                          ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'Status'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(status).withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: status,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: _getStatusColor(status),
                          ),
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Menunggu',
                              child: Text('Menunggu'),
                            ),
                            DropdownMenuItem(
                              value: 'Proses',
                              child: Text('Proses'),
                            ),
                            DropdownMenuItem(
                              value: 'Selesai',
                              child: Text('Selesai'),
                            ),
                          ],
                          onChanged: isUpdating
                              ? null
                              : (newStatus) {
                                  setState(() {
                                    status = newStatus!;
                                  });
                                },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _SectionLabel(label: 'NIS'),
                    const SizedBox(height: 4),
                    _SectionValue(value: nis),

                    const SizedBox(height: 16),

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

                    if (isStatusSelesai) ...[
                      _SectionLabel(
                        label: 'Foto Bukti Pengerjaan',
                        isRequired: true,
                      ),
                      const SizedBox(height: 8),

                      if (existingBuktiFilenames.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foto bukti sebelumnya:',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: existingBuktiFilenames.length,
                                itemBuilder: (context, index) {
                                  final buktiUrl = _getFotoUrl(
                                    existingBuktiFilenames[index],
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _showFullImage(context, buktiUrl);
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              buktiUrl,
                                              width: 150,
                                              height: 150,
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
                                                      width: 150,
                                                      height: 150,
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
                                                      width: 150,
                                                      height: 150,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 48,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () =>
                                                _removeExistingImage(index),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],

                      Text(
                        'Foto Bukti Baru',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                            if (buktiBytes != null && buktiFileName != null)
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.memory(
                                      buktiBytes!,
                                      height: 180,
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
                                        onPressed: _removeImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (buktiBytes == null)
                              InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: 130,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 40,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Klik untuk upload foto bukti',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Format: JPG, PNG (Max 5MB)',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (buktiFileName != null && buktiBytes != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  buktiFileName!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
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

                    const SizedBox(height: 20),

                    _SectionLabel(label: 'Feedback'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: feedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tulis feedback untuk siswa...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isUpdating
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              'Tutup',
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F5C66),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isUpdating ? null : _updateAspirasi,
                            child: isUpdating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Simpan Perubahan',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    status = widget.aspirasi.data['status'] ?? 'Menunggu';
    feedbackController = TextEditingController(
      text: widget.aspirasi.data['feedback']?.toString() ?? '',
    );

    final buktiData = widget.aspirasi.data['bukti_foto'];
    if (buktiData != null) {
      if (buktiData is List) {
        for (var foto in buktiData) {
          if (foto is String && foto.isNotEmpty) {
            existingBuktiFilenames.add(foto);
          }
        }
      } else if (buktiData is String && buktiData.isNotEmpty) {
        existingBuktiFilenames = [buktiData];
      }
    }
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
    return pb.files.getUrl(widget.aspirasi, filename).toString();
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
              buktiBytes = reader.result as Uint8List?;
              buktiFileName = file.name;
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

  void _removeExistingImage(int index) {
    setState(() {
      existingBuktiFilenames.removeAt(index);
    });
  }

  void _removeImage() {
    setState(() {
      buktiBytes = null;
      buktiFileName = null;
    });
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

  Future<void> _updateAspirasi() async {
    if (status == 'Selesai' &&
        buktiBytes == null &&
        existingBuktiFilenames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap upload minimal 1 foto bukti untuk status Selesai',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isUpdating = true);

    try {
      List<String> allBuktiFilenames = List.from(existingBuktiFilenames);

      if (buktiBytes != null) {
        final newBuktiFilename = await service.uploadBuktiFoto(
          aspirasiId: widget.aspirasi.id,
          fotoBytes: buktiBytes!,
          fileName: buktiFileName!,
        );
        allBuktiFilenames.add(newBuktiFilename);
      }

      await service.updateStatus(
        aspirasiId: widget.aspirasi.id,
        status: status,
        feedback: feedbackController.text,
        buktiFoto: allBuktiFilenames,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onUpdated?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aspirasi berhasil diperbarui',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _SectionLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionValue extends StatelessWidget {
  final String value;

  const _SectionValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
