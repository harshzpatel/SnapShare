import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapshare/services/auth_methods.dart';
import 'package:snapshare/screens/home_screen.dart';
import 'package:snapshare/screens/signup_screen.dart';
import 'package:snapshare/core/utils.dart';
import 'package:snapshare/widgets/footer.dart';
import 'package:snapshare/widgets/form_button.dart';
import 'package:snapshare/widgets/text_field_input.dart';

import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res == 'success') {
      if (kDebugMode) {
        print('Logged in');
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));

      await NotificationService().initialize();
    } else {
      showSnackBar(res, context);
    }
  }

  void navigateToSignup() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              _form(),
              Footer(
                text: "Don't have an account?",
                button: "Sign up",
                onTap: navigateToSignup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _form() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/app_icon.png', width: 120, height: 120),
              Text('SnapShare', style: GoogleFonts.caveatBrush(fontSize: 50)),
              const SizedBox(height: 120),
              TextFieldInput(
                textEditingController: _emailController,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: 'Password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              const SizedBox(height: 30),
              FormButton(
                text: 'Log in',
                onPressed: loginUser,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
