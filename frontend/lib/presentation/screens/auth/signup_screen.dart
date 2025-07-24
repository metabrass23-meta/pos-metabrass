import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/auth_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../widgets/premium_text_button.dart';
import '../../widgets/premium_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please accept the terms and conditions',
              style: GoogleFonts.inter(fontSize: context.captionFontSize),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      ).then((_) {
        if (authProvider.state == AuthState.authenticated) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Branding
          Expanded(
            flex: ResponsiveBreakpoints.responsive(
              context,
              tablet: 2,
              small: 2,
              medium: 2,
              large: 2,
              ultrawide: 2,
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppTheme.secondaryMaroon,
                    AppTheme.primaryMaroon,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.iconSize('special') * 1.5,
                      height: context.iconSize('special') * 1.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.pureWhite,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: context.shadowBlur(),
                            offset: Offset(0, context.smallPadding),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.diamond_sharp,
                        size: context.iconSize('special'),
                        color: AppTheme.primaryMaroon,
                      ),
                    ),

                    SizedBox(height: context.mainPadding),

                    Text(
                      'Join Our',
                      style: GoogleFonts.inter(
                        fontSize: context.headerFontSize,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.pureWhite.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: context.smallPadding),

                    Text(
                      'Premium Family',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: context.headingFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.pureWhite,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: context.cardPadding),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: context.mainPadding),
                      child: Text(
                        'Begin your journey with us and discover the epitome of luxury fashion. \nCreate your account to access exclusive collections and personalized service.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.pureWhite.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Side - Signup Form
          Expanded(
            flex: ResponsiveBreakpoints.responsive(
              context,
              tablet: 2,
              small: 2,
              medium: 1,
              large: 1,
              ultrawide: 1,
            ),
            child: Container(
              color: AppTheme.creamWhite,
              child: Center(
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: context.maxContentWidth * 0.5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create Account',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: context.headingFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalGray,
                              letterSpacing: -0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: context.smallPadding),

                          Text(
                            'Join our exclusive community',
                            style: GoogleFonts.inter(
                              fontSize: context.headerFontSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: context.mainPadding * 1.5),

                          // Full Name Field
                          PremiumTextField(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your full name';
                              }
                              if (value!.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: context.formFieldSpacing),

                          // Email Field
                          PremiumTextField(
                            label: 'Email Address',
                            hint: 'Enter your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: context.formFieldSpacing),

                          // Password Field
                          PremiumTextField(
                            label: 'Password',
                            hint: 'Create a strong password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: context.iconSize('medium'),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter a password';
                              }
                              if (value!.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                                return 'Password must contain uppercase, lowercase, and number';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: context.formFieldSpacing),

                          // Confirm Password Field
                          PremiumTextField(
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: context.iconSize('medium'),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: context.cardPadding),

                          // Terms and Conditions
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: context.iconSize('medium'),
                                  height: context.iconSize('medium'),
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _acceptTerms = value ?? false;
                                      });
                                    },
                                    activeColor: AppTheme.primaryMaroon,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.smallPadding * 2),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: context.smallPadding / 4),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'I agree to the ',
                                            style: GoogleFonts.inter(
                                              fontSize: context.bodyFontSize,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: GoogleFonts.inter(
                                              fontSize: context.bodyFontSize,
                                              color: AppTheme.primaryMaroon,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' and ',
                                            style: GoogleFonts.inter(
                                              fontSize: context.bodyFontSize,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: GoogleFonts.inter(
                                              fontSize: context.bodyFontSize,
                                              color: AppTheme.primaryMaroon,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: context.mainPadding),

                          // Signup Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return PremiumButton(
                                text: 'Create Account',
                                onPressed: authProvider.isLoading ? null : _handleSignup,
                                isLoading: authProvider.isLoading,
                                height: context.buttonHeight / 1.5,
                              );
                            },
                          ),

                          SizedBox(height: context.cardPadding),

                          // Error Message
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.errorMessage != null) {
                                return Container(
                                  padding: EdgeInsets.all(context.smallPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: GoogleFonts.inter(
                                      color: Colors.red.shade700,
                                      fontSize: context.bodyFontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          SizedBox(height: context.mainPadding),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.inter(
                                  fontSize: context.bodyFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: context.headerFontSize,
                                    color: AppTheme.primaryMaroon,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}