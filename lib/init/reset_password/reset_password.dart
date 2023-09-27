import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/constants/sizes.dart';
import 'package:bijou_cafe/constants/texts.dart';
import 'package:bijou_cafe/init/login/login_controller.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final Function(bool) setResetPasswordVisible;

  const ResetPasswordScreen({super.key, required this.setResetPasswordVisible});

  @override
  State<ResetPasswordScreen> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final LoginController loginController = LoginController();

  final TextEditingController emailTextController = TextEditingController();

  bool _isLoading = false;

  Future<void> _performPasswordReset(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      loginController.sendPasswordResetEmail(context, emailTextController.text);
      // ignore: use_build_context_synchronously
      Toast.show(context,
          "A link to reset your password has been sent to your email.");

      widget.setResetPasswordVisible(false);
    } catch (e) {
      Toast.show(context, e.toString());
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
            SizedBox(
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _performPasswordReset(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('RESET PASSWORD'),
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
                  widget.setResetPasswordVisible(false);
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
