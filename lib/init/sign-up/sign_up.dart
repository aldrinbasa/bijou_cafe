import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/constants/sizes.dart';
import 'package:bijou_cafe/constants/texts.dart';
import 'package:bijou_cafe/init/login/login_controller.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final Function(bool) setSignUpVisible;

  const SignUpScreen({super.key, required this.setSignUpVisible});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final LoginController loginController = LoginController();

  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _performSignUp(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (emailTextController.text.isEmpty) {
        Toast.show(context, "Email is required.");
      } else if (!isEmailValid(emailTextController.text)) {
        Toast.show(
            context, "${emailTextController.text} is not a valid email.");
      } else if (firstNameTextController.text.isEmpty) {
        Toast.show(context, "First name is required.");
      } else if (lastNameTextController.text.isEmpty) {
        Toast.show(context, "Last name is required.");
      } else if (passwordTextController.text.isEmpty) {
        Toast.show(context, "Password is required.");
      } else if (passwordTextController.text.length < 6) {
        Toast.show(context, "Password must be greater than 6 characters.");
      } else {
        await loginController.signUp(
          context,
          emailTextController.text,
          firstNameTextController.text,
          lastNameTextController.text,
          passwordTextController.text,
        );

        // ignore: use_build_context_synchronously
        Toast.show(context,
            "Successfully signed-up! Check your email to verify your account.");

        widget.setSignUpVisible(false);
      }
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
                hintText: 'juan.delacruz@email.com',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                labelStyle: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: firstNameTextController,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  color: primaryColor,
                ),
                labelText: firstName,
                hintText: 'Juan',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                labelStyle: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameTextController,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  color: primaryColor,
                ),
                labelText: lastName,
                hintText: 'Dela Cruz',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                labelStyle: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _performSignUp(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(signUp.toUpperCase()),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor,
                  width: 0.25,
                ),
              ),
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.setSignUpVisible(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                ),
                child: Text(
                  back.toUpperCase(),
                  style: const TextStyle(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
