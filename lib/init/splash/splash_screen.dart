import 'package:flutter/material.dart';
import 'package:bijou_cafe/constants/image_paths.dart';
import 'package:bijou_cafe/constants/texts.dart';
import 'package:bijou_cafe/init/login/login_controller.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/page_transition.dart';
import 'package:bijou_cafe/init/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().whenComplete(() {
      PageTransition.pushRightNavigation(context, const LoginScreen());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    checkLoggedInStatus(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SlideTransition(
              position: _animation,
              child: Image(
                image: const AssetImage(bijouCafeLogo),
                height: size.height * 0.2,
              ),
            ),
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                loginSubtitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void checkLoggedInStatus(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString('user_email');
  String? userFirstName = prefs.getString('user_first_name');
  String? userLastName = prefs.getString('user_last_name');
  String? userType = prefs.getString('user_type');
  String? userUid = prefs.getString('user_uid');
  double? userCreditBalance = prefs.getDouble('user_credit');
  double? userPaypalBalance = prefs.getDouble('user_paypal');

  if (userEmail != null && userFirstName != null && userLastName != null) {
    LoginController loginController = LoginController();
    UserModel loggedInUser = UserModel(
        uid: userUid!,
        email: userEmail,
        firstName: userFirstName,
        lastName: userLastName,
        userType: userType!,
        creditBalance: userCreditBalance!,
        paypalBalance: userPaypalBalance!);

    // ignore: use_build_context_synchronously
    loginController.setUser(loggedInUser, context);
  }
}
