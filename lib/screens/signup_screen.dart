import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapshare/services/auth_methods.dart';
import 'package:snapshare/screens/login_screen.dart';
import 'package:snapshare/core/theme.dart';
import 'package:snapshare/core/utils.dart';
import 'package:snapshare/widgets/text_field_input.dart';

import '../services/notification_service.dart';
import '../widgets/footer.dart';
import '../widgets/form_button.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    setState(() {
      _image = img;
    });
  }

  Future<void> signUpUser() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      file: _image,
    );

    if (kDebugMode) {
      print(res);
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (res == 'success') {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));

      await NotificationService().initialize();
    } else {
      showSnackBar(res, context);
    }
  }

  void navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
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
                text: "Already have an account?",
                button: "Log in",
                onTap: navigateToLogin,
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
            children: [
              Text('SnapShare', style: GoogleFonts.caveatBrush(fontSize: 60)),
              SizedBox(height: 64),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: _image != null
                        ? MemoryImage(_image!)
                        : AssetImage('assets/profile_icon.jpg'),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.background,
                        child: Icon(
                          size: 36,
                          Icons.add_circle_rounded,
                          color: AppColors.paleWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 54),
              TextFieldInput(
                textEditingController: _usernameController,
                hintText: 'Username',
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 15),
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
              SizedBox(height: 15),
              TextFieldInput(
                textEditingController: _bioController,
                hintText: 'Bio',
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 30),
              FormButton(
                text: 'Sign up',
                onPressed: signUpUser,
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
