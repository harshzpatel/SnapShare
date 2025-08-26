import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapshare/resources/auth_methods.dart';
import 'package:snapshare/screens/home_screen.dart';
import 'package:snapshare/screens/signup_screen.dart';
import 'package:snapshare/theme/theme.dart';
import 'package:snapshare/utils/utils.dart';
import 'package:snapshare/widgets/footer.dart';
import 'package:snapshare/widgets/form_button.dart';
import 'package:snapshare/widgets/text_field_input.dart';

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
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      showSnackBar(res, context);
    }
  }

  void navigateToSignup() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
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
          physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
                height: 64,
              ),
              SizedBox(height: 150),
              TextFieldInput(
                textEditingController: _emailController,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: 'Password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              SizedBox(height: 30),
              FormButton(
                text: 'Log in',
                onPressed: loginUser,
                isLoading: _isLoading,
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
