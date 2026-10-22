import 'package:flutter/material.dart';

import '../core/astro_chart.dart';
import '../core/astro_coach_client.dart';
import '../core/birth_profile.dart';
import '../core/numerology.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.profile,
    required this.chartService,
    required this.coachService,
    required this.onEditProfile,
    super.key,
  });

  final BirthProfile profile;
  final ChartService chartService;
  final CoachService coachService;
  final VoidCallback onEditProfile;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<AstroChart> _chartFuture;
  AstroReading? _reading;
  bool _isReading = false;
  String? _readingError;

  @override
  void initState() {
    super.initState();
    _chartFuture = widget.chartService.calculate(widget.profile);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile ||
        oldWidget.chartService != widget.chartService) {
      _chartFuture = widget.chartService.calculate(widget.profile);
      _reading = null;
      _readingError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<AstroChart>(
          future: _chartFuture,
          builder: (context, snapshot) {
            final chart = snapshot.data;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
                  sliver: SliverList.list(
                    children: [
                      _topBar(),
                      const SizedBox(height: 28),
                      _intro(),
                      const SizedBox(height: 18),
                      if (snapshot.connectionState != ConnectionState.done)
                        const _LoadingPanel(
                          message: 'Membaca peta langitmu di perangkat ini…',
                        )
                      else if (snapshot.hasError || chart == null)
                        _ChartError(onRetry: _retryChart)
                      else
                        _chartContent(chart),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() => Row(
    children: [
      const Icon(Icons.auto_awesome, color: AstroPalette.gold, size: 22),
      const SizedBox(width: 9),
      const Text(
        'AstroGuide',
        style: TextStyle(
          color: AstroPalette.parchment,
          fontFamily: 'serif',
          fontSize: 20,
        ),
      ),
      const Spacer(),
      TextButton.icon(
        onPressed: widget.onEditProfile,
        icon: const Icon(Icons.tune, size: 18),
        label: const Text('Ubah profil'),
      ),
    ],
  );

  Widget _intro() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Peta energimu',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AstroPalette.parchment,
          fontFamily: 'serif',
          fontSize: 34,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Halo ${widget.profile.nickname}. Kenali polamu dengan rasa ingin tahu, bukan dengan batasan.',
        style: const TextStyle(color: AstroPalette.muted, fontSize: 15),
      ),
    ],
  );

  Widget _chartContent(AstroChart chart) {
    final numbers = PythagoreanNumerology.calculate(widget.profile.fullName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrbitDial(chart: chart),
        const SizedBox(height: 14),
        Text(
          'Sidereal ${chart.ayanamsha.label}',
          style: const TextStyle(color: AstroPalette.gold, fontSize: 13),
        ),
        const SizedBox(height: 18),
        _positionLine('☀️', 'Sun', chart.sun),
        _positionLine('🌙', 'Moon', chart.moon),
        _positionLine('🌅', 'Rising', chart.rising),
        if (!chart.birthTimeKnown) ...[
          const SizedBox(height: 8),
          const Text(
            'Jam lahir belum diketahui. Rising dan rumah tidak akan ditebak.',
            style: TextStyle(color: AstroPalette.muted, fontSize: 13),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 17),
        const Text(
          'Energi nama',
          style: TextStyle(
            color: AstroPalette.parchment,
            fontFamily: 'serif',
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '${widget.profile.fullName} membawa pola angka yang bisa jadi bahan refleksi.',
          style: const TextStyle(color: AstroPalette.muted),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            _NumberTag(label: 'Ekspresi', value: numbers.expression),
            _NumberTag(label: 'Batin', value: numbers.soulUrge),
            _NumberTag(label: 'Persona', value: numbers.personality),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _isReading ? null : () => _requestReading(chart, numbers),
          icon: _isReading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome, size: 19),
          label: Text(
            _reading == null ? 'Buat bacaan AstroGuide' : 'Buat bacaan baru',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: AstroPalette.gold,
            foregroundColor: AstroPalette.ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        if (_readingError != null) ...[
          const SizedBox(height: 12),
          _InlineMessage(message: _readingError!),
        ],
        if (_reading != null) ...[
          const SizedBox(height: 32),
          AstroReadingView(
            reading: _reading!,
            profile: widget.profile,
            chart: chart,
            onQuestionSelected: (question) =>
                _requestReading(chart, numbers, question: question),
            isLoading: _isReading,
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Astrologi dan numerologi adalah alat refleksi, bukan kepastian nasib.',
          style: TextStyle(color: AstroPalette.muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _positionLine(String symbol, String label, String? sign) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(symbol, style: const TextStyle(fontSize: 18)),
        ),
        SizedBox(
          width: 92,
          child: Text(label, style: const TextStyle(color: AstroPalette.muted)),
        ),
        Expanded(
          child: Text(
            sign ?? 'Belum cukup data untuk memastikan',
            style: TextStyle(
              color: sign == null ? AstroPalette.muted : AstroPalette.parchment,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  void _retryChart() {
    setState(() {
      _chartFuture = widget.chartService.calculate(widget.profile);
    });
  }

  Future<void> _requestReading(
    AstroChart chart,
    NumerologyNumbers numbers, {
    String? question,
  }) async {
    setState(() {
      _isReading = true;
      _readingError = null;
    });
    try {
      final reading = await widget.coachService.read(
        chart: chart,
        numerology: numbers,
        question: question,
      );
      if (mounted) {
        setState(() => _reading = reading);
      }
    } on CoachException catch (error) {
      if (mounted) {
        setState(() => _readingError = error.message);
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _readingError =
              'Bacaan belum tersedia. Periksa koneksi server lalu coba lagi.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isReading = false);
      }
    }
  }
}

class AstroReadingView extends StatelessWidget {
  const AstroReadingView({
    required this.reading,
    required this.profile,
    required this.chart,
    required this.onQuestionSelected,
    required this.isLoading,
    super.key,
  });

  final AstroReading reading;
  final BirthProfile profile;
  final AstroChart chart;
  final ValueChanged<String> onQuestionSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo ${profile.nickname}! ${reading.opening}',
          style: const TextStyle(
            color: AstroPalette.parchment,
            fontFamily: 'serif',
            fontSize: 22,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 26),
        _SectionHeading('✨ PROFILE ENERGI UTAMAMU ✨'),
        const SizedBox(height: 12),
        _ProfileBullet(
          symbol: '👤',
          title: 'Nama Lengkap',
          detail: '${profile.fullName} — ${reading.nameInsight}',
        ),
        _ProfileBullet(
          symbol: '☀️',
          title: 'Sun Sign (Inti Diri)',
          detail: _placement(chart.sun, reading.sunInsight),
        ),
        _ProfileBullet(
          symbol: '🌙',
          title: 'Moon Sign (Dunia Batin)',
          detail: _placement(chart.moon, reading.moonInsight),
        ),
        _ProfileBullet(
          symbol: '🌅',
          title: 'Rising Sign (Kesan Pertama)',
          detail: _placement(chart.rising, reading.risingInsight),
        ),
        const SizedBox(height: 23),
        const _SectionHeading('🔮 ANALISIS MENDALAM (THE BIG THREE)'),
        const SizedBox(height: 12),
        _Insight(
          title: '🪐 1. Persona & Sinergi Nama',
          body: _placement(chart.sun, reading.sunInsight),
        ),
        _Insight(
          title: '🌊 2. Kedalaman Emosi',
          body: _placement(chart.moon, reading.moonInsight),
        ),
        _Insight(
          title: '🎯 3. Potensi Karir & Cinta',
          body:
              reading.careerLoveInsight ??
              'Data Mars dan Venus belum cukup untuk menyusun bagian ini.',
        ),
        const SizedBox(height: 20),
        _SectionHeading(
          '💡 ASTRO-ADVICE UNTUK ${profile.nickname.toUpperCase()}',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AstroPalette.gold, width: 3),
            ),
          ),
          child: Text(
            '“${reading.advice}”',
            style: const TextStyle(
              color: AstroPalette.parchment,
              fontFamily: 'serif',
              fontSize: 18,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bagian mana yang paling mencerminkan dirimu?',
          style: TextStyle(color: AstroPalette.muted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reading.questions
              .map(
                (question) => ActionChip(
                  label: Text(question),
                  onPressed: isLoading
                      ? null
                      : () => onQuestionSelected(question),
                  backgroundColor: AstroPalette.plum,
                  side: const BorderSide(color: AstroPalette.line),
                  labelStyle: const TextStyle(color: AstroPalette.parchment),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _placement(String? sign, String? insight) {
    if (sign == null || insight == null) {
      return 'Belum cukup data untuk memastikan. Tidak ada tanda yang ditebak.';
    }
    return '$sign — $insight';
  }
}

class _ProfileBullet extends StatelessWidget {
  const _ProfileBullet({
    required this.symbol,
    required this.title,
    required this.detail,
  });

  final String symbol;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$symbol $title: '),
          TextSpan(
            text: detail,
            style: const TextStyle(color: AstroPalette.muted),
          ),
        ],
      ),
      style: const TextStyle(color: AstroPalette.parchment, height: 1.5),
    ),
  );
}

class _Insight extends StatelessWidget {
  const _Insight({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AstroPalette.seaGlass,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(body, style: const TextStyle(color: AstroPalette.parchment)),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AstroPalette.gold,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 9),
      Container(height: 1, color: AstroPalette.line),
    ],
  );
}

class _NumberTag extends StatelessWidget {
  const _NumberTag({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AstroPalette.plum,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  color: AstroPalette.gold,
                  fontFamily: 'serif',
                  fontSize: 22,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: AstroPalette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _OrbitDial extends StatelessWidget {
  const _OrbitDial({required this.chart});

  final AstroChart chart;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 190,
    child: Stack(
      alignment: Alignment.center,
      children: [
        const Positioned.fill(child: CustomPaint(painter: _OrbitPainter())),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 25, color: AstroPalette.gold),
            const SizedBox(height: 5),
            Text(
              chart.sun ?? 'Peta langit',
              style: const TextStyle(
                color: AstroPalette.parchment,
                fontFamily: 'serif',
                fontSize: 21,
              ),
            ),
            const Text(
              'sidereal',
              style: TextStyle(color: AstroPalette.muted, fontSize: 12),
            ),
          ],
        ),
        Positioned(
          left: 10,
          top: 30,
          child: _OrbitLabel(symbol: '☀️', sign: chart.sun),
        ),
        Positioned(
          right: 4,
          top: 49,
          child: _OrbitLabel(symbol: '🌙', sign: chart.moon),
        ),
        Positioned(
          bottom: 18,
          child: _OrbitLabel(symbol: '🌅', sign: chart.rising),
        ),
      ],
    ),
  );
}

class _OrbitLabel extends StatelessWidget {
  const _OrbitLabel({required this.symbol, required this.sign});

  final String symbol;
  final String? sign;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AstroPalette.plum,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AstroPalette.line),
    ),
    child: Text(
      '$symbol  ${sign ?? 'Belum pasti'}',
      style: const TextStyle(color: AstroPalette.parchment, fontSize: 12),
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
      center,
      66,
      paint..color = AstroPalette.gold.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      center,
      86,
      paint
        ..color = AstroPalette.seaGlass.withValues(alpha: 0.35)
        ..strokeWidth = 0.8,
    );
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 180, height: 110),
      -0.3,
      2.7,
      false,
      paint
        ..color = AstroPalette.gold.withValues(alpha: 0.75)
        ..strokeWidth = 1.1,
    );
    final starPaint = Paint()..color = AstroPalette.gold;
    for (final point in [
      Offset(center.dx - 75, center.dy + 25),
      Offset(center.dx + 58, center.dy - 65),
      Offset(center.dx + 73, center.dy + 42),
      Offset(center.dx - 22, center.dy - 87),
    ]) {
      canvas.drawCircle(point, 1.6, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 42),
    child: Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AstroPalette.muted),
        ),
      ],
    ),
  );
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _InlineMessage(
        message: 'Peta langit belum bisa dihitung. Periksa data lahir, lalu coba lagi.',
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Hitung ulang'),
      ),
    ],
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AstroPalette.plum,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(message, style: const TextStyle(color: AstroPalette.danger)),
  );
}
