import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'wave_clipper.dart';

class AppHeader extends StatelessWidget {
  final bool showLogo;
  final bool showActions;
  final bool showBack;
  final String? title;
  final Color? titleColor;
  final double contentTopOffset;

  const AppHeader({
    super.key,
    this.showLogo = true,
    this.showActions = true,
    this.showBack = false,
    this.title,
    this.titleColor,
    this.contentTopOffset = 10,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const gradientHeight = 120.0;
    const waveHeight = 72.0;
    final totalHeight = topPadding + gradientHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // GRADIENTE
          Container(
            height: totalHeight,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
          ),

          // ONDA BRANCA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: waveHeight,
                color: const Color(0xFFFFF8F1),
              ),
            ),
          ),

          // CONTEÚDO
          Positioned(
            top: topPadding + contentTopOffset,
            left: 20,
            right: 20,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOPO – título com seta à esquerda e ícones à direita
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showBack)
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                      ),
                    if (showBack) const SizedBox(width: 10),
                    if (title != null)
                      Text(
                        title!,
                        style: GoogleFonts.poppins(
                          color: titleColor ?? Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )
                    else if (showLogo)
                      Image.asset(
                        'assets/logo-3.png',
                        height: 56,
                        fit: BoxFit.contain,
                      ),
                    const Spacer(),
                    if (showActions) ...[
                      _icon(Icons.notifications_none, () {}),
                      const SizedBox(width: 10),
                      _icon(
                        Icons.person_outline,
                        () => Navigator.of(context).pushNamed('/perfil'),
                      ),
                    ],
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}
