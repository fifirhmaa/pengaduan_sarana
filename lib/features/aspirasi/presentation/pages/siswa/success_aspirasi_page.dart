import 'package:flutter/material.dart';

Future<T?> showSuccessAspirasiModal<T>(BuildContext context) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const SuccessAspirasiModal();
    },
  );
}

class SuccessAspirasiModal extends StatelessWidget {
  const SuccessAspirasiModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Image.asset('lib/assets/success.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aspirasi berhasil dikirim!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terimakasih atas aspirasi anda. Kami akan segera menindak lanjutinya.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5C6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                'Lihat Riwayat Aspirasi',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pushReplacementNamed(context, '/riwayat-aspirasi');
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0B5C6B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.send, color: Color(0xFF0B5C6B)),
              label: const Text(
                'Kirim Aspirasi Lain',
                style: TextStyle(color: Color(0xFF0B5C6B)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0B5C6B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.home, color: Color(0xFF0B5C6B)),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(color: Color(0xFF0B5C6B)),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
