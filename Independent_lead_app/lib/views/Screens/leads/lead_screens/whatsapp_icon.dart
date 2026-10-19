// lib/views/Screens/leads/common/whatsapp_icon.dart  (NEW)
// Official WhatsApp glyph (same SVG path already used in leadsviewscreen.dart).
// Needs flutter_svg (already in your project).

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color kWhatsAppGreen = Color(0xFF25D366);
const Color kWhatsAppDark = Color(0xFF128C7E);

const String kWhatsAppGlyphSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

/// Single-colour WhatsApp glyph. Tint it with [color].
class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;
  const WhatsAppIcon({super.key, this.size = 20, this.color = kWhatsAppGreen});

  @override
  Widget build(BuildContext context) => SvgPicture.string(
        kWhatsAppGlyphSvg,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

/// Brand badge: green gradient tile + white glyph.
class WhatsAppLogo extends StatelessWidget {
  final double size;
  final bool circle;
  const WhatsAppLogo({super.key, this.size = 40, this.circle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5CE27A), Color(0xFF1FAF38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * .32),
        boxShadow: [
          BoxShadow(
            color: kWhatsAppGreen.withOpacity(.40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: WhatsAppIcon(size: size * .60, color: Colors.white),
      ),
    );
  }
}