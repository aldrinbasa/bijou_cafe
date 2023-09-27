import 'package:bijou_cafe/init/reset_password/reset_password.dart';
import 'package:bijou_cafe/init/sign-up/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:bijou_cafe/constants/sizes.dart';
import 'package:bijou_cafe/init/login/login_header.dart';
import 'package:bijou_cafe/init/login/login_form.dart';
import 'package:bijou_cafe/init/login/login_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool signUpVisible = false;
  bool resetPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(defaultSize),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                LoginHeader(size: size),
                SizedBox(height: size.height * 0.02),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: signUpVisible
                      ? SignUpScreen(
                          setSignUpVisible: (isVisible) {
                            setState(() {
                              signUpVisible = isVisible;
                            });
                          },
                        )
                      : resetPasswordVisible
                          ? ResetPasswordScreen(
                              setResetPasswordVisible: (isVisible) {
                              setState(() {
                                resetPasswordVisible = isVisible;
                              });
                            })
                          : LoginForm(setResetPasswordVisible: (isVisible) {
                              setState(() {
                                resetPasswordVisible = isVisible;
                              });
                            }),
                ),
                signUpVisible || resetPasswordVisible
                    ? const SizedBox(height: 1)
                    : LoginFooter(
                        setSignUpVisible: (isVisible) {
                          setState(() {
                            signUpVisible = isVisible;
                          });
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
