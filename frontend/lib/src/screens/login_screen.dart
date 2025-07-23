import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'placeholder_screen.dart';

/// Login screen for the Elegant Bridal POS application.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(_emailController.text, _passwordController.text);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlaceholderScreen()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error', style: GoogleFonts.playfairDisplay()),
            content: Text('Invalid email or password.', style: GoogleFonts.roboto()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFECE0C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 30.w,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || !value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: const Text('Login'),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      'Create an account',
                      style: GoogleFonts.roboto(fontSize: 10.sp, color: const Color(0xFFD4AF37)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}