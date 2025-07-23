import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../src/providers/app_provider.dart';
import '../src/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
    _progressController.forward();

    await Provider.of<AppProvider>(context, listen: false).initialize();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryMaroon,
              AppTheme.secondaryMaroon,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoController.value,
                    child: Opacity(
                      opacity: _logoController.value,
                      child: Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.pureWhite,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2.5.w,
                              offset: Offset(0, 1.2.w),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.diamond_sharp,
                          size: 30.sp, // Changed from 7.w to 8.sp for better icon scaling
                          color: AppTheme.primaryMaroon,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 4.h),

              // Company Name Animation
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textController.value,
                    child: Transform.translate(
                      offset: Offset(0, 2.5.h * (1 - _textController.value)),
                      child: Column(
                        children: [
                          Text(
                            'Maqbool Fabrics',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20.5.sp, // Changed from 4.w to 5.sp for better text scaling
                              fontWeight: FontWeight.w700,
                              color: AppTheme.pureWhite,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Premium Bridal & Groom Collections',
                            style: GoogleFonts.inter(
                                fontSize: 12.4.sp, // Changed from 2.w to 2.5.sp for better text scaling
                              fontWeight: FontWeight.w300,
                              color: AppTheme.pureWhite.withOpacity(0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 7.h),

              // Progress Indicator
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Container(
                    width: 25.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.2.w),
                      color: AppTheme.pureWhite.withOpacity(0.3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressController.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.2.w),
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}