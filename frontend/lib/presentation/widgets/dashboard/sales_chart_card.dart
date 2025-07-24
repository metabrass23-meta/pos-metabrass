import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/dashboard_provider.dart';
import '../../../src/theme/app_theme.dart';

class SalesChartCard extends StatelessWidget {
  const SalesChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1.w,
            offset: Offset(0, 0.5.w),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: Colors.blue,
                  size: 2.5.sp,
                ),
              ),

              SizedBox(width: 1.5.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Overview',
                      style: GoogleFonts.inter(
                        fontSize: 2.2.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'Last 6 months performance',
                      style: GoogleFonts.inter(
                        fontSize: 1.5.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Time Period Selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  '6M',
                  style: GoogleFonts.inter(
                    fontSize: 1.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Chart Area
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                final chartData = provider.salesChart;

                return CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: SalesChartPainter(chartData),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Sales', AppTheme.primaryMaroon),
              SizedBox(width: 3.w),
              _buildLegendItem('Target', AppTheme.accentGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 1.w,
          height: 1.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(0.5.w),
          ),
        ),
        SizedBox(width: 0.8.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 1.5.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class SalesChartPainter extends CustomPainter {
  final List<Map<String, double>> data;

  SalesChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryMaroon
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryMaroon.withOpacity(0.3),
          AppTheme.primaryMaroon.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    if (data.isEmpty) return;

    final maxValue = data.map((e) => e['sales']!).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e['sales']!).reduce((a, b) => a < b ? a : b);

    final path = Path();
    final gradientPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i]['sales']! - minValue) / (maxValue - minValue)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }

      // Draw data points
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = AppTheme.primaryMaroon
          ..style = PaintingStyle.fill,
      );

      // Draw white border around points
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Complete gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Draw gradient fill
    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}