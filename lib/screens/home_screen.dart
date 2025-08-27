import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:snapshare/providers/user_provider.dart';
import 'package:snapshare/core/theme.dart';
import 'package:snapshare/core/global_variables.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();

    pageController = PageController();
    addData();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  Future<void> addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  void logOut() {
    FirebaseAuth.instance.signOut();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
      bottomNavigationBar: _navBar(),
    );
  }

  Column _navBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey[900]),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _page,
          onTap: navigationTapped,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/home.svg',
                colorFilter: ColorFilter.mode(
                  _page == 0 ? AppColors.primary : AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Home',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/search.svg',
                colorFilter: ColorFilter.mode(
                  _page == 1 ? AppColors.primary : AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Search',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/add_box.svg',
                colorFilter: ColorFilter.mode(
                  _page == 2 ? AppColors.primary : AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Add',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/heart.svg',
                colorFilter: ColorFilter.mode(
                  _page == 3 ? AppColors.primary : AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Fav',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/profile.svg',
                colorFilter: ColorFilter.mode(
                  _page == 4 ? AppColors.primary : AppColors.secondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Pro',
              // backgroundColor: primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}
