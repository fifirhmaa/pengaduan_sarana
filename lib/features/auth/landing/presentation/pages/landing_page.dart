import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../aspirasi/presentation/pages/siswa/input_aspirasi_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Responsive sizing
    final isTablet = screenWidth >= 600;
    final isSmallPhone = screenWidth < 360;

    // Responsive image height
    final imageHeight = screenHeight * (isTablet ? 0.28 : 0.22);

    // Responsive font sizes
    final titleFontSize = isTablet ? 32.0 : (isSmallPhone ? 20.0 : 24.0);
    final subtitleFontSize = isTablet ? 18.0 : (isSmallPhone ? 13.0 : 15.0);
    final buttonFontSize = isTablet ? 18.0 : (isSmallPhone ? 14.0 : 16.0);

    // Responsive spacing
    final topSpacing = screenHeight * (isTablet ? 0.1 : 0.08);
    final buttonSpacing = screenHeight * (isSmallPhone ? 0.012 : 0.016);
    final bottomSpacing = screenHeight * 0.08;

    // Responsive button height
    final buttonHeight = isTablet ? 64.0 : (isSmallPhone ? 48.0 : 56.0);

    // Responsive padding
    final horizontalPadding = isTablet ? 48.0 : (isSmallPhone ? 24.0 : 32.0);

    // Check orientation
    final isLandscape = screenWidth > screenHeight;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: isLandscape ? topSpacing * 0.5 : topSpacing,
                        ),

                        // Illustration with responsive sizing
                        Hero(
                          tag: 'landing_illustration',
                          child: Image.asset(
                            'lib/assets/landing.png',
                            height: imageHeight,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * (isTablet ? 0.05 : 0.04),
                        ),

                        // Title with responsive layout
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.8,
                          ),
                          child: Text(
                            'APLIKASI ASPIRASI SEKOLAH',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Text(
                            isTablet
                                ? 'Sampaikan aspirasi dan keluhan untuk\nlingkungan sekolah yang lebih baik'
                                : 'Sampaikan aspirasi dan keluhan untuk\nlingkungan sekolah yang lebih baik',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Buttons section with responsive layout
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            children: [
                              // Kirim Aspirasi Button
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F5C66),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isTablet ? 16 : 12,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const InputAspirasiPage(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        size: buttonFontSize + 4,
                                      ),
                                      SizedBox(width: isTablet ? 16 : 12),
                                      Flexible(
                                        child: Text(
                                          'Kirim Aspirasi',
                                          style: GoogleFonts.poppins(
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: buttonSpacing),

                              // Riwayat Button
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F5C66),
                                    side: const BorderSide(
                                      color: Color(0xFF0F5C66),
                                      width: 1.5,
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isTablet ? 16 : 12,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/riwayat-aspirasi',
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history_rounded,
                                        size: buttonFontSize + 4,
                                      ),
                                      SizedBox(width: isTablet ? 16 : 12),
                                      Flexible(
                                        child: Text(
                                          'Riwayat',
                                          style: GoogleFonts.poppins(
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: buttonSpacing),

                              // Admin Button
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F5C66),
                                    side: const BorderSide(
                                      color: Color(0xFF0F5C66),
                                      width: 1.5,
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isTablet ? 16 : 12,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/admin-login',
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings_rounded,
                                        size: buttonFontSize + 4,
                                      ),
                                      SizedBox(width: isTablet ? 16 : 12),
                                      Flexible(
                                        child: Text(
                                          'Admin',
                                          style: GoogleFonts.poppins(
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: bottomSpacing),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
