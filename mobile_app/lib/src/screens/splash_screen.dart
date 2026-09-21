import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'customer_home_screen.dart';
import 'owner_home_screen.dart';
import 'language_selection_screen.dart';
import '../theme/onboarding_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initialize() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();
      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) =>
                    authProvider.isOwner
                        ? const OwnerHomeScreen()
                        : const CustomerHomeScreen(),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (error, stack) {
      debugPrint('Startup initialization failed: $error');
      debugPrintStack(stackTrace: stack);
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Unable to start the app. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _errorMessage == null
          ? GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LanguageSelectionScreen(
                      onContinue: _initialize,
                    ),
                  ),
                );
              },
              child: const _DawaeiSplashDesign(),
            )
          : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _initialize();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _DawaeiSplashDesign extends StatelessWidget {
  const _DawaeiSplashDesign();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [onboardingPrimaryColor, Color(0xFF1769AA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SplashBackgroundPainter())),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _MedicineLogo(),
                  const SizedBox(height: 22),
                  const Text(
                    'دوائي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 39,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Dawaei',
                    style: TextStyle(
                      color: Color(0xFFB9DCFF),
                      fontSize: 23,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'دواؤك أقرب .. وسعرك أفضل',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Your Medicine Closer .. Better Price',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineLogo extends StatelessWidget {
  const _MedicineLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 126,
      height: 126,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.18,
            child: Container(
              width: 118,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFB9DCFF), width: 5),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          const Icon(
            Icons.location_on,
            size: 112,
            color: Colors.white,
          ),
          const Positioned(
            top: 25,
            child: Icon(Icons.add, size: 44, color: Color(0xFF1769AA)),
          ),
          Positioned(
            bottom: 27,
            child: Transform.rotate(
              angle: -0.55,
              child: Container(
                width: 39,
                height: 17,
                decoration: BoxDecoration(
                  color: const Color(0xFF1769AA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()..color = const Color(0x22006F70);
    final wave = Path()
      ..moveTo(0, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.31,
        size.width * 0.53,
        size.height * 0.20,
      )
      ..quadraticBezierTo(
        size.width * 0.77,
        size.height * 0.10,
        size.width,
        size.height * 0.05,
      )
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(0, size.height * 0.58)
      ..close();
    canvas.drawPath(wave, wavePaint);

    final skylinePaint =
        Paint()
          ..color = const Color(0x4484E8D5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final baseline = size.height - 18;
    for (var x = 0.0; x < size.width; x += 28) {
      final height = 18.0 + ((x * 7).toInt() % 42).toDouble();
      canvas.drawRect(
        Rect.fromLTWH(x, baseline - height, 20, height),
        skylinePaint,
      );
      canvas.drawLine(
        Offset(x + 4, baseline - height),
        Offset(x + 10, baseline - height - 9),
        skylinePaint,
      );
      canvas.drawLine(
        Offset(x + 10, baseline - height - 9),
        Offset(x + 16, baseline - height),
        skylinePaint,
      );
    }
    canvas.drawLine(Offset(0, baseline), Offset(size.width, baseline), skylinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
