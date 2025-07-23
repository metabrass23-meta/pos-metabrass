import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../src/theme/app_theme.dart';

class PremiumTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool enabled;

  const PremiumTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _borderColorAnimation = ColorTween(
      begin: const Color(0xFFE0E0E0),
      end: AppTheme.primaryMaroon,
    ).animate(_animationController);

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          style: GoogleFonts.inter(
            fontSize: 11.sp, // Changed from 2.w to 2.sp for better text scaling
            fontWeight: FontWeight.w400,
            color: AppTheme.charcoalGray,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
              widget.prefixIcon,
              size: 13.sp, // Changed from 2.4.w to 3.sp for better icon scaling
              color: _isFocused
                  ? AppTheme.primaryMaroon
                  : const Color(0xFF9E9E9E),
            )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled ? AppTheme.pureWhite : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.w),
              borderSide: BorderSide(
                color: _borderColorAnimation.value ?? const Color(0xFFE0E0E0),
                width: 0.1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.w),
              borderSide: BorderSide(
                color: const Color(0xFFE0E0E0),
                width: 0.1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.w),
              borderSide: BorderSide(
                color: AppTheme.primaryMaroon,
                width: 0.2.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.w),
              borderSide: BorderSide(
                color: Colors.red,
                width: 0.1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.w),
              borderSide: BorderSide(
                color: Colors.red,
                width: 0.2.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 2.h,
              horizontal: 2.w,
            ),
            labelStyle: GoogleFonts.inter(
              color: _isFocused ? AppTheme.primaryMaroon : const Color(0xFF9E9E9E),
              fontSize: 11.8.sp, // Changed from 1.8.w to 1.8.sp for better text scaling
              fontWeight: FontWeight.w500,
            ),
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF9E9E9E),
              fontSize: 1.8.sp, // Changed from 1.8.w to 1.8.sp for better text scaling
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}