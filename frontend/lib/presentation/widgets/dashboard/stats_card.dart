import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/theme/app_theme.dart';

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Handle card tap
                },
                borderRadius: BorderRadius.circular(context.borderRadius()), // Responsive border radius
                child: Container(
                  padding: EdgeInsets.all(context.cardPadding), // Responsive padding
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(context.borderRadius()), // Responsive border radius

                    border: Border.all(
                      color: widget.color.withOpacity(0.1),
                      width: 0.05.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.smallPadding), // Responsive padding
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(context.borderRadius('small')), // Responsive border radius
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: context.iconSize('medium'), // Responsive icon size
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.smallPadding, // Responsive horizontal padding
                              vertical: context.smallPadding * 0.5, // Responsive vertical padding
                            ),
                            decoration: BoxDecoration(
                              color: widget.isPositive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(context.borderRadius('small')), // Responsive border radius
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.isPositive
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: widget.isPositive ? Colors.green : Colors.red,
                                  size: context.iconSize('small'), // Responsive icon size
                                ),
                                SizedBox(width: context.smallPadding * 0.5), // Responsive spacing
                                Text(
                                  widget.change,
                                  style: GoogleFonts.inter(
                                    fontSize: context.captionFontSize, // Responsive caption font
                                    fontWeight: FontWeight.w600,
                                    color: widget.isPositive ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: context.formFieldSpacing * 2), // Responsive spacing

                      // Value
                      Text(
                        widget.value,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: context.headingFontSize, // Responsive heading font
                          fontWeight: FontWeight.w700,
                          color: AppTheme.charcoalGray,
                          letterSpacing: -0.5,
                        ),
                      ),

                      SizedBox(height: context.formFieldSpacing * 0.5), // Responsive spacing

                      // Title
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize, // Responsive subtitle font
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          letterSpacing: 0.2,
                        ),
                      ),

                      SizedBox(height: context.formFieldSpacing), // Responsive spacing

                      // Progress Bar
                      Container(
                        height: context.formFieldHeight * 0.1, // Responsive height
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(context.borderRadius('small')), // Responsive border radius
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: widget.isPositive ? 0.7 : 0.4,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color,
                                  widget.color.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(context.borderRadius('small')), // Responsive border radius
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}