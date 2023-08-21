import 'package:flutter/material.dart';
import 'package:bijou_cafe/constants/sizes.dart';
import 'package:bijou_cafe/init/login/login_header.dart';
import 'package:bijou_cafe/init/login/login_form.dart';
import 'package:bijou_cafe/init/login/login_footer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                const LoginForm(),
                const LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
