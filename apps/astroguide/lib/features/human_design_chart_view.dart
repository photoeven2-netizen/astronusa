import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../core/birth_profile.dart';
import '../core/human_design_calculator.dart';
import '../theme/app_theme.dart';

class BodygraphImageRenderer {
  static Future<Uint8List> renderPngBytes(HumanDesignChart hdChart) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(650, 680);

    // Dark Background
    final bgPaint = Paint()..color = const Color(0xFF1B122C);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Render Left Side: Tubuh (Red Design Placements)
    _drawPlanetColumn(
      canvas: canvas,
      x: 15,
      yStart: 20,
      width: 150,
      headerTitle: 'Tubuh',
      headerBgColor: const Color(0xFFB71C1C),
      cardBgColor: const Color(0xFF8B0000),
      placements: hdChart.designPlacements,
    );

    // 2. Render Center: Bodygraph Silhouette & Centers
    canvas.save();
    canvas.translate(170, 40);
    final centerPainter = _BodygraphPainter(hdChart: hdChart);
    centerPainter.paint(canvas, const Size(310, 600));
    canvas.restore();

    // 3. Render Right Side: Jiwa (Black/Gold Personality Placements)
    _drawPlanetColumn(
      canvas: canvas,
      x: 485,
      yStart: 20,
      width: 150,
      headerTitle: 'Jiwa',
      headerBgColor: const Color(0xFF332244),
      cardBgColor: const Color(0xFF110B1E),
      placements: hdChart.personalityPlacements,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static void _drawPlanetColumn({
    required Canvas canvas,
    required double x,
    required double yStart,
    required double width,
    required String headerTitle,
    required Color headerBgColor,
    required Color cardBgColor,
    required List<HdGatePlacement> placements,
  }) {
    // Header Badge
    final headerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, yStart, width, 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(headerRect, Paint()..color = headerBgColor);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      text: headerTitle,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
    textPainter.layout(minWidth: width, maxWidth: width);
    textPainter.paint(canvas, Offset(x, yStart + 6));

    double currentY = yStart + 38;
    const double cardHeight = 36;
    const double gap = 8;

    for (final p in placements) {
      final cardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, currentY, width, cardHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(cardRect, Paint()..color = cardBgColor);
      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Symbol + Planet Name (Left)
      final symbol = _planetSymbol(p.planetName);
      final name = _translatedPlanetName(p.planetName);

      textPainter.text = TextSpan(
        text: '$symbol $name',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      );
      textPainter.layout(maxWidth: width - 42);
      textPainter.paint(canvas, Offset(x + 8, currentY + 10));

      // Gate.Line Number (Right)
      textPainter.text = TextSpan(
        text: p.label,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + width - 38, currentY + 9));

      currentY += cardHeight + gap;
    }
  }

  static String _planetSymbol(String name) => switch (name) {
    'Sun' => '☉',
    'Earth' => '⊕',
    'North Node' => '☊',
    'South Node' => '☋',
    'Moon' => '☽',
    'Mercury' => '☿',
    'Venus' => '♀',
    'Mars' => '♂',
    'Jupiter' => '♃',
    'Saturn' => '♄',
    'Uranus' => '♅',
    'Neptune' => '♆',
    'Pluto' => '♇',
    _ => '•',
  };

  static String _translatedPlanetName(String name) => switch (name) {
    'Sun' => 'Matahari',
    'Earth' => 'Bumi',
    'North Node' => 'Node U',
    'South Node' => 'Node S',
    'Moon' => 'Bulan',
    'Mercury' => 'Merkurius',
    'Venus' => 'Venus',
    'Mars' => 'Mars',
    'Jupiter' => 'Jupiter',
    'Saturn' => 'Saturnus',
    'Uranus' => 'Uranus',
    'Neptune' => 'Neptunus',
    'Pluto' => 'Pluto',
    _ => name,
  };
}

class HumanDesignChartView extends StatelessWidget {
  const HumanDesignChartView({
    required this.hdChart,
    required this.profile,
    super.key,
  });

  final HumanDesignChart hdChart;
  final BirthProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Title
        Center(
          child: Column(
            children: [
              const Text(
                'Human Design',
                style: TextStyle(
                  color: AstroPalette.parchment,
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Penjelasan Lengkap Chart untuk ${profile.fullName}',
                style: const TextStyle(
                  color: AstroPalette.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(profile.birthDate)}${profile.birthTimeMinutes != null ? ", ${_formatTime(profile.birthTimeMinutes!)}" : ""} · ${profile.cityName}',
                style: const TextStyle(
                  color: AstroPalette.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Three Column Bodygraph Layout (Tubuh | Diagram | Jiwa)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Tubuh (Design / Merah / Bawah Sadar)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Tubuh',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...hdChart.designPlacements.map((p) => _PlanetTag(
                    symbol: _planetSymbol(p.planetName),
                    planetName: p.planetName,
                    gateLine: p.label,
                    color: Colors.red.shade900,
                  )),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Center Column: Interactive Human Silhouette Bodygraph Visual
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 520,
                child: CustomPaint(
                  painter: _BodygraphPainter(hdChart: hdChart),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Right Column: Jiwa (Personality / Hitam / Sadar)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AstroPalette.plum,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AstroPalette.line),
                    ),
                    child: const Text(
                      'Jiwa',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...hdChart.personalityPlacements.map((p) => _PlanetTag(
                    symbol: _planetSymbol(p.planetName),
                    planetName: p.planetName,
                    gateLine: p.label,
                    color: AstroPalette.plum,
                  )),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Core Summary Highlights Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AstroPalette.plum,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AstroPalette.line),
          ),
          child: Column(
            children: [
              _HighlightRow(label: 'Tipe Energi', value: hdChart.type),
              const Divider(color: AstroPalette.line, height: 16),
              _HighlightRow(label: 'Strategi', value: hdChart.strategy),
              const Divider(color: AstroPalette.line, height: 16),
              _HighlightRow(label: 'Authority', value: hdChart.authority),
              const Divider(color: AstroPalette.line, height: 16),
              _HighlightRow(label: 'Profil', value: hdChart.profileLabel),
              const Divider(color: AstroPalette.line, height: 16),
              _HighlightRow(label: 'Definition', value: hdChart.definitionType),
              const Divider(color: AstroPalette.line, height: 16),
              _HighlightRow(label: 'Misi Hidup', value: hdChart.incarnationCross),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  String _planetSymbol(String name) => switch (name) {
    'Sun' => '☉',
    'Earth' => '⊕',
    'North Node' => '☊',
    'South Node' => '☋',
    'Moon' => '☽',
    'Mercury' => '☿',
    'Venus' => '♀',
    'Mars' => '♂',
    'Jupiter' => '♃',
    'Saturn' => '♄',
    'Uranus' => '♅',
    'Neptune' => '♆',
    'Pluto' => '♇',
    _ => '•',
  };
}

class _PlanetTag extends StatelessWidget {
  const _PlanetTag({
    required this.symbol,
    required this.planetName,
    required this.gateLine,
    required this.color,
  });

  final String symbol;
  final String planetName;
  final String gateLine;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$symbol ${_translatedPlanetName(planetName)}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          Text(
            gateLine,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _translatedPlanetName(String name) => switch (name) {
    'Sun' => 'Matahari',
    'Earth' => 'Bumi',
    'North Node' => 'Node U',
    'South Node' => 'Node S',
    'Moon' => 'Bulan',
    'Mercury' => 'Merkurius',
    'Venus' => 'Venus',
    'Mars' => 'Mars',
    'Jupiter' => 'Jupiter',
    'Saturn' => 'Saturnus',
    'Uranus' => 'Uranus',
    'Neptune' => 'Neptunus',
    'Pluto' => 'Pluto',
    _ => name,
  };
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AstroPalette.muted, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AstroPalette.parchment,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _BodygraphPainter extends CustomPainter {
  _BodygraphPainter({required this.hdChart});

  final HumanDesignChart hdChart;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Background Human Silhouette Contour
    _drawHumanSilhouette(canvas, size);

    // 2. Define Center Coordinates inside Human Body
    final centerCoords = <HdCenter, Offset>{
      HdCenter.head: Offset(w * 0.5, h * 0.08),
      HdCenter.ajna: Offset(w * 0.5, h * 0.20),
      HdCenter.throat: Offset(w * 0.5, h * 0.35),
      HdCenter.gCenter: Offset(w * 0.5, h * 0.50),
      HdCenter.heart: Offset(w * 0.74, h * 0.57),
      HdCenter.spleen: Offset(w * 0.24, h * 0.67),
      HdCenter.sacral: Offset(w * 0.5, h * 0.67),
      HdCenter.solarPlexus: Offset(w * 0.76, h * 0.67),
      HdCenter.root: Offset(w * 0.5, h * 0.88),
    };

    // 3. Draw Channels
    final linePaint = Paint()
      ..color = Colors.grey.shade600.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final activeChannelPaint = Paint()
      ..color = AstroPalette.gold
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    for (final ch in HumanDesignCalculator.allChannels) {
      final posA = centerCoords[ch.centerA]!;
      final posB = centerCoords[ch.centerB]!;
      final isActive = hdChart.activeChannels.contains(ch);
      canvas.drawLine(posA, posB, isActive ? activeChannelPaint : linePaint);
    }

    // 4. Draw 9 Centers
    for (final entry in centerCoords.entries) {
      final center = entry.key;
      final pos = entry.value;
      final isDefined = hdChart.isCenterDefined(center);

      final fillPaint = Paint()
        ..color = isDefined
            ? (center == HdCenter.sacral ? Colors.red.shade800 : AstroPalette.gold)
            : Colors.grey.shade900.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isDefined ? Colors.amber.shade200 : AstroPalette.line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      _drawCenterShape(canvas, center, pos, fillPaint, borderPaint);
    }
  }

  void _drawHumanSilhouette(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = Colors.grey.shade300.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.grey.shade400.withValues(alpha: 0.45)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Head Contour (Top Oval)
    final headPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.14),
        width: w * 0.52,
        height: h * 0.22,
      ));

    // Neck & Torso Contour
    final torsoPath = Path()
      ..moveTo(w * 0.42, h * 0.24)
      // Left Shoulder
      ..quadraticBezierTo(w * 0.35, h * 0.29, w * 0.08, h * 0.35)
      // Left Ribs
      ..quadraticBezierTo(w * 0.04, h * 0.52, w * 0.12, h * 0.70)
      // Left Hip / Thigh
      ..quadraticBezierTo(w * 0.15, h * 0.85, w * 0.22, h * 0.96)
      // Bottom Base
      ..lineTo(w * 0.78, h * 0.96)
      // Right Hip / Thigh
      ..quadraticBezierTo(w * 0.85, h * 0.85, w * 0.88, h * 0.70)
      // Right Ribs
      ..quadraticBezierTo(w * 0.96, h * 0.52, w * 0.92, h * 0.35)
      // Right Shoulder
      ..quadraticBezierTo(w * 0.65, h * 0.29, w * 0.58, h * 0.24)
      ..close();

    canvas.drawPath(headPath, bodyPaint);
    canvas.drawPath(headPath, outlinePaint);

    canvas.drawPath(torsoPath, bodyPaint);
    canvas.drawPath(torsoPath, outlinePaint);
  }

  void _drawCenterShape(
    Canvas canvas,
    HdCenter center,
    Offset pos,
    Paint fillPaint,
    Paint borderPaint,
  ) {
    const double radius = 22.0;

    switch (center) {
      case HdCenter.head:
      case HdCenter.ajna:
        // Triangle
        final path = Path()
          ..moveTo(pos.dx, pos.dy - radius)
          ..lineTo(pos.dx - radius, pos.dy + radius * 0.8)
          ..lineTo(pos.dx + radius, pos.dy + radius * 0.8)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case HdCenter.gCenter:
        // Diamond
        final path = Path()
          ..moveTo(pos.dx, pos.dy - radius)
          ..lineTo(pos.dx + radius, pos.dy)
          ..lineTo(pos.dx, pos.dy + radius)
          ..lineTo(pos.dx - radius, pos.dy)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case HdCenter.heart:
        // Small Triangle
        final path = Path()
          ..moveTo(pos.dx - radius * 0.8, pos.dy - radius * 0.8)
          ..lineTo(pos.dx + radius * 0.8, pos.dy)
          ..lineTo(pos.dx - radius * 0.8, pos.dy + radius * 0.8)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      default:
        // Square
        final rect = Rect.fromCenter(center: pos, width: radius * 1.8, height: radius * 1.8);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BodygraphPainter oldDelegate) =>
      oldDelegate.hdChart != hdChart;
}
