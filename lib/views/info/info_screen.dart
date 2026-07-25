import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Smart Chef — About screen
///
/// Design concept: "Kitchen Ticket". The page reads like a printed order
/// ticket from an open kitchen — a dark header torn away from a parchment
/// body, receipt-style mono labels, and a stamped seal for the credit card.
///
/// Dependencies to add to pubspec.yaml if not already present:
///   dependencies:
///     google_fonts: ^6.2.1
///     url_launcher: ^6.3.0
/// ─────────────────────────────────────────────────────────────────────────

// ---- Design tokens ---------------------------------------------------

const kInk = Color(0xFF2B2320); // near-black kitchen-slate
const kParchment = Color(0xFFF3EADB); // warm ticket paper
const kRule = Color(0xFFE4D8C3); // ruled line on the paper
const kSaffron = Color(0xFFE8A93B); // spice accent
const kSage = Color(0xFF5E7360); // herb accent
const kRust = Color(0xFFA64B37); // clay accent
const kInkFaded = Color(0xFF6E655F);

TextStyle _display(
        {double size = 26,
        FontWeight weight = FontWeight.w600,
        Color color = kInk}) =>
    GoogleFonts.fraunces(
        fontSize: size, fontWeight: weight, color: color, height: 1.1);

TextStyle _body(
        {double size = 14,
        FontWeight weight = FontWeight.w400,
        Color color = kInk}) =>
    GoogleFonts.karla(
        fontSize: size, fontWeight: weight, color: color, height: 1.4);

TextStyle _mono(
        {double size = 11,
        FontWeight weight = FontWeight.w500,
        Color color = kInkFaded,
        double spacing = 1.6}) =>
    GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing);

// ---- Screen ------------------------------------------------------------

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _stagger(double start, double end) => CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kParchment,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _TicketHeader(onBack: () => Navigator.pop(context)),
              _FadeIn(
                animation: _stagger(0.15, 0.55),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _brand(),
                      const SizedBox(height: 40),
                      _lineLabel('CRAFTED BY'),
                      const SizedBox(height: 14),
                      _DeveloperStampCard(
                          onTapLink: () => _openUrl(
                              'https://www.linkedin.com/in/dharmendra-reddy-m-s-8289211b1')),
                    ],
                  ),
                ),
              ),
              _FadeIn(
                animation: _stagger(0.35, 0.75),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _lineLabel("WHAT'S IN THE POT"),
                      const SizedBox(height: 14),
                      _IngredientRow(
                        index: '01',
                        title: 'Smart recipe suggestions',
                        note: 'from what you already have',
                      ),
                      _IngredientRow(
                        index: '02',
                        title: 'Ingredient scanning',
                        note: 'point, snap, cook',
                      ),
                      _IngredientRow(
                        index: '03',
                        title: 'Saved favorites',
                        note: 'your own recipe box',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 44),
              _FadeIn(
                animation: _stagger(0.55, 0.9),
                child: const _TicketFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Smart Chef', style: _display(size: 30)),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('— No. 001', style: _mono(size: 11, color: kRust)),
        ),
      ],
    );
  }

  Widget _lineLabel(String text) {
    return Row(
      children: [
        Text(text, style: _mono(color: kInk, weight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: kRule),
        ),
      ],
    );
  }
}

// ---- Header: ticket torn away from the parchment body -----------------

class _TicketHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _TicketHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _TornEdgeClipper(),
          child: Container(
            height: 168,
            width: double.infinity,
            color: kInk,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back,
                            color: kParchment, size: 22),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 4),
                        child: _StampSeal(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('ORDER TICKET',
                        style: _mono(
                            color: kSaffron,
                            weight: FontWeight.w700,
                            spacing: 3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 4),
                    child: Text('About this kitchen',
                        style: GoogleFonts.fraunces(
                          color: kParchment,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
        // punch holes riding the torn seam
        Positioned(
          bottom: 6,
          left: 0,
          right: 0,
          child: _PunchHoleRow(color: kParchment),
        ),
      ],
    );
  }
}

class _TornEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const teeth = 18;
    final toothWidth = size.width / teeth;
    const dip = 10.0;
    final path = Path()..lineTo(0, size.height - dip);
    for (int i = 0; i < teeth; i++) {
      final x1 = toothWidth * (i + 0.5);
      final x2 = toothWidth * (i + 1);
      final peak = (i.isEven ? size.height - dip - 6 : size.height - dip + 2);
      path.quadraticBezierTo(x1, peak, x2, size.height - dip);
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PunchHoleRow extends StatelessWidget {
  final Color color;
  const _PunchHoleRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        12,
        (i) => Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Stamp seal (replaces plain logo badge) ----------------------------

class _StampSeal extends StatelessWidget {
  const _StampSeal();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(64, 64), painter: _ScallopPainter()),
          ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const Icon(
                    Icons.ramen_dining_rounded,
                    color: kSaffron,
                    size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScallopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = kSaffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const scallops = 16;
    for (int i = 0; i < scallops; i++) {
      final angle = (2 * math.pi / scallops) * i;
      final x = center.dx + radius * 0.92 * math.cos(angle);
      final y = center.dy + radius * 0.92 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2.2, paint..style = PaintingStyle.fill);
    }
    canvas.drawCircle(
        center,
        radius - 6,
        Paint()
          ..color = kParchment
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---- Developer stamp card ----------------------------------------------

class _DeveloperStampCard extends StatelessWidget {
  final VoidCallback onTapLink;
  const _DeveloperStampCard({required this.onTapLink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: kRule, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kSage, width: 1.6),
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: Image.asset(
                'assets/images/dr.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                    color: kRule,
                    child: const Icon(Icons.person, color: kInkFaded)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dharmendra Reddy M S',
                    style: _display(size: 17, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('SOFTWARE DEVELOPER',
                    style:
                        _mono(size: 10, color: kSage, weight: FontWeight.w700)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onTapLink,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('view linkedin',
                          style: _mono(
                              size: 11,
                              color: kRust,
                              weight: FontWeight.w600,
                              spacing: 0.5)),
                      const SizedBox(width: 4),
                      const Icon(Icons.north_east_rounded,
                          size: 12, color: kRust),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -0.18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: kRust, width: 1.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('VERIFIED',
                  style: _mono(
                      size: 8,
                      color: kRust,
                      weight: FontWeight.w700,
                      spacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Feature / ingredient rows ------------------------------------------

class _IngredientRow extends StatelessWidget {
  final String index;
  final String title;
  final String note;
  final bool isLast;
  const _IngredientRow(
      {required this.index,
      required this.title,
      required this.note,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: kRule, width: 1)),
      ),
      child: Row(
        children: [
          Text(index,
              style: _mono(size: 12, color: kRust, weight: FontWeight.w700)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _body(size: 15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(note, style: _body(size: 12.5, color: kInkFaded)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Footer: ticket stub -------------------------------------------------

class _TicketFooter extends StatelessWidget {
  const _TicketFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            40,
            (i) => Expanded(
              child: Container(
                  height: 1.4, color: i.isEven ? kRule : Colors.transparent),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: kInk,
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Text('SMART CHEF',
                  style: _mono(
                      color: kParchment, weight: FontWeight.w700, spacing: 3)),
              const SizedBox(height: 6),
              Text('v1.0.0 · served with flutter',
                  style: _mono(size: 10, color: kSaffron, spacing: 1)),
            ],
          ),
        ),
      ],
    );
  }
}

// ---- Small fade+rise helper ----------------------------------------------

class _FadeIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _FadeIn({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
