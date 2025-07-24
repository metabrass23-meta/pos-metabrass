import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/app_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';

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
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _orbitalController;
  late AnimationController _lightRayController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoFloatAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textGlowAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbitalAnimation;
  late Animation<double> _lightRayAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with staggered durations for complexity
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _orbitalController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );
    _lightRayController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Complex logo animations with multiple phases
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_logoController);

    _logoRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.5, end: 0.2)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(_logoController);

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInQuart),
    ));

    _logoFloatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Advanced text animations
    _textSlideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 2), end: const Offset(0, -0.1))
            .chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_textController);

    _textOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_textController);

    _textGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Complex background animations
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOutSine,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _orbitalAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _orbitalController,
      curve: Curves.linear,
    ));

    _lightRayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lightRayController,
      curve: Curves.easeInOutQuad,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start background effects immediately
    _backgroundController.forward();
    _particleController.repeat();
    _orbitalController.repeat();

    // Staggered entrance with dramatic timing
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _lightRayController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Start continuous effects
    _shimmerController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();

    // Initialize app with extended timing for dramatic effect
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
    _backgroundController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _orbitalController.dispose();
    _lightRayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _particleController,
          _orbitalController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5 + (_backgroundAnimation.value * 0.5),
                colors: [
                  Color.lerp(AppTheme.primaryMaroon, AppTheme.secondaryMaroon,
                      _backgroundAnimation.value * 0.3) ?? AppTheme.primaryMaroon,
                  AppTheme.primaryMaroon,
                  Color.lerp(AppTheme.secondaryMaroon, const Color(0xFF4A0E1A),
                      _backgroundAnimation.value * 0.5) ?? AppTheme.secondaryMaroon,
                  const Color(0xFF2A0B11),
                ],
                stops: [
                  0.0,
                  0.4 + (_backgroundAnimation.value * 0.2),
                  0.8 + (_backgroundAnimation.value * 0.1),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Dynamic background pattern overlay
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: LuxuryPatternPainter(_backgroundAnimation.value),
                      );
                    },
                  ),
                ),

                // Enhanced particle system with multiple layers
                ...List.generate(25, (index) => _buildAdvancedParticle(index)),

                // Orbital light rings
                ...List.generate(3, (index) => _buildOrbitalRing(index)),

                // Light rays emanating from center
                _buildLightRays(),

                // Main content with enhanced effects
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ultra-premium logo with complex animations
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _logoController,
                          _shimmerController,
                          _pulseController,
                          _lightRayController,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value * _pulseAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, -5 * _logoFloatAnimation.value),
                                child: Opacity(
                                  opacity: _logoOpacityAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer glow ring
                                      Container(
                                        width: ResponsiveBreakpoints.responsive(
                                          context,
                                          tablet: 18.w,
                                          small: 18.w,
                                          medium: 18.w,
                                          large: 18.w,
                                          ultrawide: 18.w,
                                        ),
                                        height: ResponsiveBreakpoints.responsive(
                                          context,
                                          tablet: 18.w,
                                          small: 18.w,
                                          medium: 18.w,
                                          large: 18.w,
                                          ultrawide: 18.w,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppTheme.accentGold.withOpacity(0.1 * _lightRayAnimation.value),
                                              AppTheme.accentGold.withOpacity(0.3 * _lightRayAnimation.value),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.7, 0.85, 1.0],
                                          ),
                                        ),
                                      ),

                                      // Main logo container with advanced effects
                                      Container(
                                        width: ResponsiveBreakpoints.responsive(
                                          context,
                                          tablet: 14.w,
                                          small: 14.w,
                                          medium: 14.w,
                                          large: 14.w,
                                          ultrawide: 14.w,
                                        ),
                                        height: ResponsiveBreakpoints.responsive(
                                          context,
                                          tablet: 14.w,
                                          small: 14.w,
                                          medium: 14.w,
                                          large: 14.w,
                                          ultrawide: 14.w,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              AppTheme.pureWhite,
                                              AppTheme.pureWhite.withOpacity(0.98),
                                              AppTheme.pureWhite.withOpacity(0.95),
                                              AppTheme.pureWhite.withOpacity(0.9),
                                            ],
                                            stops: const [0.0, 0.5, 0.8, 1.0],
                                          ),
                                          boxShadow: [
                                            // Primary golden glow
                                            BoxShadow(
                                              color: AppTheme.accentGold.withOpacity(0.6 * _lightRayAnimation.value),
                                              blurRadius: context.shadowBlur('heavy') * 2,
                                              spreadRadius: 4,
                                              offset: const Offset(0, 0),
                                            ),
                                            // Secondary glow
                                            BoxShadow(
                                              color: AppTheme.accentGold.withOpacity(0.3 * _lightRayAnimation.value),
                                              blurRadius: context.shadowBlur('heavy') * 3,
                                              spreadRadius: 8,
                                              offset: const Offset(0, 0),
                                            ),
                                            // Depth shadow
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.4),
                                              blurRadius: context.shadowBlur('heavy'),
                                              offset: Offset(0, context.smallPadding * 2),
                                            ),
                                            // Inner highlight
                                            BoxShadow(
                                              color: AppTheme.pureWhite.withOpacity(0.8),
                                              blurRadius: context.shadowBlur(),
                                              spreadRadius: -2,
                                              offset: const Offset(0, -2),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Animated shimmer overlay
                                            ClipOval(
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: SweepGradient(
                                                    center: Alignment.center,
                                                    startAngle: _shimmerAnimation.value * 3.14159,
                                                    endAngle: (_shimmerAnimation.value + 1) * 3.14159,
                                                    colors: [
                                                      Colors.transparent,
                                                      AppTheme.accentGold.withOpacity(0.1),
                                                      AppTheme.accentGold.withOpacity(0.3),
                                                      AppTheme.accentGold.withOpacity(0.1),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Diamond icon with premium effects
                                            ShaderMask(
                                              shaderCallback: (bounds) => RadialGradient(
                                                colors: [
                                                  AppTheme.primaryMaroon,
                                                  AppTheme.secondaryMaroon,
                                                  AppTheme.accentGold,
                                                  AppTheme.primaryMaroon,
                                                ],
                                                stops: const [0.0, 0.3, 0.7, 1.0],
                                              ).createShader(bounds),
                                              child: Icon(
                                                Icons.diamond_sharp,
                                                size: context.iconSize('special') * 1.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: context.mainPadding * 2.5),

                      // Ultra-premium text with advanced effects
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _textController,
                          _shimmerController,
                        ]),
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textOpacityAnimation,
                              child: Column(
                                children: [
                                  // Company name with complex shader effects
                                  Stack(
                                    children: [
                                      // Glow background
                                      Text(
                                        'Maqbool Fashion',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: context.headingFontSize * 1.2,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.accentGold.withOpacity(0.3),
                                          letterSpacing: 3.0,
                                        ),
                                      ),
                                      // Main text with animated shader
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          begin: Alignment(-1.0 + _textGlowAnimation.value, -0.5),
                                          end: Alignment(1.0 + _textGlowAnimation.value, 0.5),
                                          colors: [
                                            AppTheme.pureWhite.withOpacity(0.8),
                                            AppTheme.accentGold,
                                            AppTheme.pureWhite,
                                            AppTheme.accentGold.withOpacity(0.9),
                                            AppTheme.pureWhite.withOpacity(0.8),
                                          ],
                                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                        ).createShader(bounds),
                                        child: Text(
                                          'Maqbool Fashion',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: context.headingFontSize * 1.2,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 3.0,
                                            shadows: [
                                              Shadow(
                                                color: AppTheme.accentGold.withOpacity(0.5),
                                                offset: const Offset(0, 0),
                                                blurRadius: 20,
                                              ),
                                              Shadow(
                                                color: Colors.black.withOpacity(0.5),
                                                offset: const Offset(0, 3),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: context.smallPadding * 1.5),

                                  // Animated decorative elements
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildDecorativeDiamond(),
                                      Container(
                                        width: ResponsiveBreakpoints.responsive(
                                          context,
                                          tablet: 20.w,
                                          small: 20.w,
                                          medium: 12.w,
                                          large: 15.w,
                                          ultrawide: 12.w,
                                        ),
                                        height: 3,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppTheme.accentGold.withOpacity(0.3),
                                              AppTheme.accentGold,
                                              AppTheme.accentGold.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.accentGold.withOpacity(0.5),
                                              blurRadius: 10,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildDecorativeDiamond(),
                                    ],
                                  ),

                                  SizedBox(height: context.smallPadding * 2),

                                  // Enhanced subtitle
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        AppTheme.pureWhite.withOpacity(0.9),
                                        AppTheme.accentGold.withOpacity(0.7),
                                        AppTheme.pureWhite.withOpacity(0.9),
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Premium Bridal & Groom Collections',
                                      style: GoogleFonts.inter(
                                        fontSize: context.headerFontSize,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        letterSpacing: 2.5,
                                        shadows: [
                                          Shadow(
                                            color: AppTheme.accentGold.withOpacity(0.3),
                                            offset: const Offset(0, 0),
                                            blurRadius: 15,
                                          ),
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: context.mainPadding * 3),

                      // Ultra-premium progress indicator
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _progressController,
                          _shimmerController,
                        ]),
                        builder: (context, child) {
                          return Column(
                            children: [
                              // Progress container with advanced styling
                              Container(
                                width: ResponsiveBreakpoints.responsive(
                                  context,
                                  tablet: 40.w,
                                  small: 40.w,
                                  medium: 22.w,
                                  large: 30.w,
                                  ultrawide: 22.w,
                                ),
                                height: ResponsiveBreakpoints.responsive(
                                  context,
                                  tablet: 1.2.h,
                                  small: 1.0.h,
                                  medium: 1.0.h,
                                  large: 0.8.h,
                                  ultrawide: 0.8.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(context.borderRadius('xl')),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.pureWhite.withOpacity(0.1),
                                      AppTheme.pureWhite.withOpacity(0.2),
                                      AppTheme.pureWhite.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppTheme.accentGold.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                    BoxShadow(
                                      color: AppTheme.accentGold.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Animated background glow
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(context.borderRadius('xl')),
                                        gradient: LinearGradient(
                                          begin: Alignment(-1.0 + _shimmerAnimation.value * 0.5, 0),
                                          end: Alignment(1.0 + _shimmerAnimation.value * 0.5, 0),
                                          colors: [
                                            Colors.transparent,
                                            AppTheme.accentGold.withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Progress fill with advanced gradient
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _progressController.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(context.borderRadius('xl')),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.accentGold.withOpacity(0.8),
                                              AppTheme.accentGold,
                                              const Color(0xFFFFD700),
                                              AppTheme.accentGold,
                                              AppTheme.accentGold.withOpacity(0.8),
                                            ],
                                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.accentGold.withOpacity(0.6),
                                              blurRadius: 20,
                                              offset: const Offset(0, 0),
                                            ),
                                            BoxShadow(
                                              color: AppTheme.accentGold.withOpacity(0.8),
                                              blurRadius: 5,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Animated progress shimmer
                                    if (_progressController.value > 0.1)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(context.borderRadius('xl')),
                                            gradient: LinearGradient(
                                              begin: Alignment(-1.5, 0),
                                              end: Alignment(1.5, 0),
                                              colors: [
                                                Colors.transparent,
                                                AppTheme.pureWhite.withOpacity(0.6),
                                                AppTheme.pureWhite.withOpacity(0.8),
                                                AppTheme.pureWhite.withOpacity(0.6),
                                                Colors.transparent,
                                              ],
                                              stops: [
                                                (_progressController.value - 0.4).clamp(0.0, 1.0),
                                                (_progressController.value - 0.2).clamp(0.0, 1.0),
                                                _progressController.value.clamp(0.0, 1.0),
                                                (_progressController.value + 0.2).clamp(0.0, 1.0),
                                                (_progressController.value + 0.4).clamp(0.0, 1.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(height: context.smallPadding * 2.5),

                              // Luxury loading text with glow
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppTheme.pureWhite.withOpacity(0.8),
                                    AppTheme.accentGold.withOpacity(0.9),
                                    AppTheme.pureWhite.withOpacity(0.8),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Crafting your exclusive fashion experience...',
                                  style: GoogleFonts.inter(
                                    fontSize: context.captionFontSize * 1.1,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: AppTheme.accentGold.withOpacity(0.4),
                                        offset: const Offset(0, 0),
                                        blurRadius: 12,
                                      ),
                                      Shadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: const Offset(0, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedParticle(int index) {
    final random = (index * 173) % 100;
    final size = 1.5 + (random % 6);
    final opacity = 0.05 + ((random % 40) / 100);
    final speed = 0.3 + ((random % 70) / 100);
    final delay = (random % 100) / 100;
    final horizontalDrift = ((random % 40) - 20) / 10;

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final progress = (_particleAnimation.value + delay) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final fadeOpacity = opacity * (1 - progress) * (progress > 0.1 ? 1.0 : progress * 10);

        return Positioned(
          left: ((random % 100) / 100 * screenWidth) + (horizontalDrift * progress * screenWidth * 0.1),
          top: screenHeight * (1.2 - progress * 1.4),
          child: Opacity(
            opacity: fadeOpacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: index % 3 != 0 ? BorderRadius.circular(size * 0.3) : null,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentGold.withOpacity(0.8),
                    AppTheme.accentGold.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.6),
                    blurRadius: size * 3,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitalRing(int ringIndex) {
    final radius = 100.0 + (ringIndex * 50);
    final particleCount = 8 + (ringIndex * 4);

    return AnimatedBuilder(
      animation: _orbitalController,
      builder: (context, child) {
        return Stack(
          children: List.generate(particleCount, (particleIndex) {
            final angle = (2 * 3.14159 * particleIndex / particleCount) +
                (_orbitalAnimation.value * 3.14159 * (ringIndex % 2 == 0 ? 1 : -1));
            final x = MediaQuery.of(context).size.width / 2 + radius * math.cos(angle);
            final y = MediaQuery.of(context).size.height / 2 + radius * math.sin(angle);

            return Positioned(
              left: x - 2,
              top: y - 2,
              child: Container(
                width: 4.0 - ringIndex,
                height: 4.0 - ringIndex,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGold.withOpacity(0.3 - (ringIndex * 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLightRays() {
    return AnimatedBuilder(
      animation: _lightRayController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: LightRaysPainter(_lightRayAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeDiamond() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
          child: Transform.rotate(
            angle: _shimmerAnimation.value * 0.1,
            child: Icon(
              Icons.diamond_outlined,
              size: context.iconSize('small') * 0.8,
              color: AppTheme.accentGold.withOpacity(0.8),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for luxury background pattern
class LuxuryPatternPainter extends CustomPainter {
  final double animationValue;

  LuxuryPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Create subtle geometric pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 6; i++) {
      final radius = 50.0 + (i * 40) + (animationValue * 20);
      paint.color = AppTheme.accentGold.withOpacity(0.1 - (i * 0.015));

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Add radiating lines
    for (int i = 0; i < 12; i++) {
      final angle = (i * 3.14159 * 2 / 12) + (animationValue * 0.5);
      final startRadius = 80;
      final endRadius = 200;

      paint.color = AppTheme.accentGold.withOpacity(0.05);
      canvas.drawLine(
        Offset(
          centerX + startRadius * math.cos(angle),
          centerY + startRadius * math.sin(angle),
        ),
        Offset(
          centerX + endRadius * math.cos(angle),
          centerY + endRadius * math.sin(angle),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LuxuryPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Custom painter for light rays effect
class LightRaysPainter extends CustomPainter {
  final double animationValue;

  LightRaysPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create dramatic light rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14159 * 2 / 8);
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          AppTheme.accentGold.withOpacity(0.1 * animationValue),
          Colors.transparent,
        ],
      );

      paint.shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: size.width,
          height: size.height,
        ),
      );

      final path = Path();
      path.moveTo(centerX, centerY);
      path.lineTo(
        centerX + size.width * math.cos(angle),
        centerY + size.height * math.sin(angle),
      );
      path.lineTo(
        centerX + size.width * math.cos(angle + 0.2),
        centerY + size.height * math.sin(angle + 0.2),
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
