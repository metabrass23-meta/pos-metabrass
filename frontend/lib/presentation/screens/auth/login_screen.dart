// import 'package:flutter/material.dart';
// import 'package:frontend/presentation/widgets/premium_text_button.dart';
// import 'package:frontend/presentation/widgets/premium_text_field.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sizer/sizer.dart';
// import '../../../src/providers/auth_provider.dart';
// import '../../../src/theme/app_theme.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _handleLogin() {
//     if (_formKey.currentState?.validate() ?? false) {
//       Provider.of<AuthProvider>(context, listen: false).login(
//         _emailController.text,
//         _passwordController.text,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Left Side - Branding
//           Expanded(
//             flex: 3,
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     AppTheme.primaryMaroon,
//                     AppTheme.secondaryMaroon,
//                   ],
//                 ),
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 12.w,
//                       height: 12.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppTheme.pureWhite,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 1.8.w,
//                             offset: Offset(0, 1.w),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.diamond_sharp,
//                         size: 30.sp, // Changed from 6.w to 7.sp for better icon scaling
//                         color: AppTheme.primaryMaroon,
//                       ),
//                     ),
//
//                     SizedBox(height: 4.h),
//
//                     Text(
//                       'Welcome Back to',
//                       style: GoogleFonts.inter(
//                         fontSize: 14.5.sp, // Changed from 2.2.w to 2.5.sp for better text scaling
//                         fontWeight: FontWeight.w300,
//                         color: AppTheme.pureWhite.withOpacity(0.9),
//                       ),
//                     ),
//
//                     SizedBox(height: 1.h),
//
//                     Text(
//                       'Maqbool Fabrics',
//                       style: GoogleFonts.playfairDisplay(
//                         fontSize: 20.5.sp, // Changed from 4.5.w to 5.5.sp for better text scaling
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.pureWhite,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//
//                     SizedBox(height: 2.h),
//
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 4.w),
//                       child: Text(
//                         'Crafting elegance for your most precious moments. \nExperience luxury redefined through our premium bridal and groom collections.',
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.inter(
//                           fontSize: 10.4.sp, // Changed from 2.w to 2.2.sp for better text scaling
//                           fontWeight: FontWeight.w300,
//                           color: AppTheme.pureWhite.withOpacity(0.8),
//                           height: 1.6,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Right Side - Login Form
//           Expanded(
//             flex: 2,
//             child: Container(
//               color: AppTheme.creamWhite,
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(6.w),
//                   child: Container(
//                     constraints: BoxConstraints(maxWidth: 50.w),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Text(
//                             'Sign In',
//                             style: GoogleFonts.playfairDisplay(
//                               fontSize: 18.sp, // Changed from 3.5.w to 4.sp for better text scaling
//                               fontWeight: FontWeight.w600,
//                               color: AppTheme.charcoalGray,
//                               letterSpacing: -0.3,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//
//                           SizedBox(height: 1.h),
//
//                           Text(
//                             'Access Your Premium Dashboard',
//                             style: GoogleFonts.inter(
//                               fontSize: 12.sp, // Changed from 1.8.w to 2.sp for better text scaling
//                               fontWeight: FontWeight.w400,
//                               color: Colors.grey[600],
//                               height: 1.4,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//
//                           SizedBox(height: 6.h),
//
//                           // Email Field
//                           PremiumTextField(
//                             label: 'Email Address',
//                             hint: 'Enter your email',
//                             controller: _emailController,
//                             keyboardType: TextInputType.emailAddress,
//                             prefixIcon: Icons.email_outlined,
//                             validator: (value) {
//                               if (value?.isEmpty ?? true) {
//                                 return 'Please enter your email';
//                               }
//                               if (!value!.contains('@')) {
//                                 return 'Please enter a valid email';
//                               }
//                               return null;
//                             },
//                           ),
//
//                           SizedBox(height: 3.h),
//
//                           // Password Field
//                           PremiumTextField(
//                             label: 'Password',
//                             hint: 'Enter your password',
//                             controller: _passwordController,
//                             obscureText: _obscurePassword,
//                             prefixIcon: Icons.lock_outline,
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _obscurePassword = !_obscurePassword;
//                                 });
//                               },
//                               icon: Icon(
//                                 _obscurePassword
//                                     ? Icons.visibility_outlined
//                                     : Icons.visibility_off_outlined,
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value?.isEmpty ?? true) {
//                                 return 'Please enter your password';
//                               }
//                               if (value!.length < 6) {
//                                 return 'Password must be at least 6 characters';
//                               }
//                               return null;
//                             },
//                           ),
//
//                           SizedBox(height: 2.h),
//
//                           // Forgot Password
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: TextButton(
//                               onPressed: () {
//                                 // Handle forgot password
//                               },
//                               child: Text(
//                                 'Forgot Password?',
//                                 style: GoogleFonts.inter(
//                                   fontSize: 10.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
//                                   color: AppTheme.primaryMaroon,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(height: 4.h),
//
//                           // Login Button
//                           Consumer<AuthProvider>(
//                             builder: (context, authProvider, child) {
//                               return PremiumButton(
//                                 text: 'Sign In',
//                                 onPressed: authProvider.isLoading ? null : _handleLogin,
//                                 isLoading: authProvider.isLoading,
//                                 height: 7.h,
//                               );
//                             },
//                           ),
//
//                           SizedBox(height: 3.h),
//
//                           // Error Message
//                           Consumer<AuthProvider>(
//                             builder: (context, authProvider, child) {
//                               if (authProvider.errorMessage != null) {
//                                 return Container(
//                                   padding: EdgeInsets.all(1.5.h),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade50,
//                                     borderRadius: BorderRadius.circular(1.w),
//                                     border: Border.all(color: Colors.red.shade200),
//                                   ),
//                                   child: Text(
//                                     authProvider.errorMessage!,
//                                     style: GoogleFonts.inter(
//                                       color: Colors.red.shade700,
//                                       fontSize: 9.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//
//                           SizedBox(height: 4.h),
//
//                           // Sign Up Link
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Don't have an account?",
//                                 style: GoogleFonts.inter(
//                                   fontSize: 11.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, '/signup');
//                                 },
//                                 child: Text(
//                                   'Sign Up',
//                                   style: GoogleFonts.inter(
//                                     fontSize: 11.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
//                                     color: AppTheme.primaryMaroon,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/auth_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/premium_text_button.dart';
import '../../widgets/premium_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.login(
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
            flex: 3,
            child: Container(
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
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.pureWhite,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 1.8.w,
                            offset: Offset(0, 1.w),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_florist,
                        size: 7.sp, // Changed from 6.w to 7.sp for better icon scaling
                        color: AppTheme.primaryMaroon,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Welcome Back to',
                      style: GoogleFonts.inter(
                        fontSize: 2.5.sp, // Changed from 2.2.w to 2.5.sp for better text scaling
                        fontWeight: FontWeight.w300,
                        color: AppTheme.pureWhite.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Maqbool Fabric',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 5.5.sp, // Changed from 4.5.w to 5.5.sp for better text scaling
                        fontWeight: FontWeight.w700,
                        color: AppTheme.pureWhite,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Crafting elegance for your most precious moments. Experience luxury redefined through our premium bridal and groom collections.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 2.2.sp, // Changed from 2.w to 2.2.sp for better text scaling
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

          // Right Side - Login Form
          Expanded(
            flex: 2,
            child: Container(
              color: AppTheme.creamWhite,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(6.w),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 50.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign In',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 4.sp, // Changed from 3.5.w to 4.sp for better text scaling
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalGray,
                              letterSpacing: -0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 1.h),

                          Text(
                            'Access your premium dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 2.sp, // Changed from 1.8.w to 2.sp for better text scaling
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 6.h),

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
                              if (!value!.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 3.h),

                          // Password Field
                          PremiumTextField(
                            label: 'Password',
                            hint: 'Enter your password',
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
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your password';
                              }
                              if (value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 2.h),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Handle forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  fontSize: 1.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
                                  color: AppTheme.primaryMaroon,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 4.h),

                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return PremiumButton(
                                text: 'Sign In',
                                onPressed: authProvider.isLoading ? null : _handleLogin,
                                isLoading: authProvider.isLoading,
                                height: 7.h,
                              );
                            },
                          ),

                          SizedBox(height: 3.h),

                          // Error Message
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.errorMessage != null) {
                                return Container(
                                  padding: EdgeInsets.all(1.5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(1.w),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: GoogleFonts.inter(
                                      color: Colors.red.shade700,
                                      fontSize: 1.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          SizedBox(height: 4.h),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.inter(
                                  fontSize: 1.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 1.8.sp, // Changed from 1.7.w to 1.8.sp for better text scaling
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