import 'package:flutter/material.dart';
import 'package:bijou_cafe/init/login/login_controller.dart';

import 'package:bijou_cafe/constants/sizes.dart';
import 'package:bijou_cafe/constants/texts.dart';
import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/utils/toast.dart';

class LoginForm extends StatefulWidget {
  final Function(bool) setResetPasswordVisible;
  const LoginForm({Key? key, required this.setResetPasswordVisible})
      : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final LoginController loginController = LoginController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _performLogin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await loginController.signInWithEmail(
        context,
        emailTextController.text,
        passwordTextController.text,
      );
    } catch (e) {
      Toast.show(context, vagueError);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: formHeight - 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailTextController,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  color: primaryColor,
                ),
                labelText: email,
                hintText: email,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                labelStyle: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: formHeight),
            TextField(
              controller: passwordTextController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock,
                  color: primaryColor,
                ),
                labelText: 'Password',
                hintText: 'Enter your password',
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                  color: primaryColor,
                ),
              ),
              obscureText: !_showPassword,
              onSubmitted: (_) {
                _performLogin(context);
              },
            ),
            const SizedBox(height: formHeight - 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  widget.setResetPasswordVisible(true);
                },
                child: const Text(forgotPassword),
              ),
            ),
            SizedBox(
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _performLogin(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(login.toUpperCase()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
