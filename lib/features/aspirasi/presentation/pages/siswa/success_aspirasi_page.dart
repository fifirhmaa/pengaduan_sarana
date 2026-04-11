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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isDesktop = screenSize.width >= 1200;
    final isSmallPhone = screenSize.width < 360;

    final outerHorizontalPadding = isDesktop
        ? 32.0
        : (isTablet ? 16.0 : (isSmallPhone ? 6.0 : 8.0));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: outerHorizontalPadding,
        vertical: 24,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 40 : 32,
          horizontal: isTablet ? 32 : 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(
            color: const Color(0xFF0F5C66).withOpacity(0.15),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: isTablet ? 150 : 120,
              child: Image.asset('lib/assets/success.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(
              'Aspirasi berhasil dikirim!',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terimakasih atas aspirasi anda. Kami akan segera menindak lanjutinya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5C6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 18 : 16,
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
                Navigator.pop(context);
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
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 18 : 16,
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
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 18 : 16,
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
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
