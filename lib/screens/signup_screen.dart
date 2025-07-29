import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/widgets/text_field_input.dart';

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
          child: Column(children: [_form(), _footer()]),
        ),
      ),
    );
  }

  Expanded _form() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                height: 64,
              ),
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
                        backgroundColor: Colors.black,
                        child: Icon(
                          size: 36,
                          Icons.add_circle_rounded,
                          color: Color(0xfff4f5f7),
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signUpUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        )
                      : Text(
                          'Sign up',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Row _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("Already have an account?"),
        ),
        GestureDetector(
          onTap: navigateToLogin,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              " Log in",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
