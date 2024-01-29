import 'dart:math';

import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrediCheckoutDialog extends StatefulWidget {
  final OnlineOrderModel order;
  final UserModel? loggedInUser = UserSingleton().user;

  CrediCheckoutDialog({Key? key, required this.order}) : super(key: key);

  @override
  State<CrediCheckoutDialog> createState() => _CreditCheckoutDialogState();
}

class _CreditCheckoutDialogState extends State<CrediCheckoutDialog> {
  late double remainingBalance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    calculateRemainingBalance();
  }

  void calculateRemainingBalance() {
    remainingBalance = widget.loggedInUser!.creditBalance -
        widget.order.totalPrice -
        widget.order.deliveryCharge;
  }

  @override
  Widget build(BuildContext context) {
    bool isBalanceEnough = remainingBalance >= 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/credit-card-logo.png',
                  width: 100,
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Review Your Order',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderDetails(),
            const SizedBox(height: 24),
            _buildTermsAndConditions(),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBalanceEnough ? Colors.black : Colors.grey,
              ),
              onPressed: isBalanceEnough && !isLoading
                  ? () {
                      _startPaymentProcessing();
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const CircularProgressIndicator(color: Colors.white),
                    if (!isLoading)
                      const Icon(Icons.credit_card, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isLoading ? 'Processing...' : 'Charge',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            if (!isBalanceEnough)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Your wallet balance is not enough.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    Random random = Random();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderDetailRow(
              'CCard No.', '${random.nextInt(9000) + 1000}-****-****'),
          _buildOrderDetailRow(
              'VCC', '${random.nextInt(11) + 1}/${random.nextInt(30)}'),
          _buildOrderDetailRow('Total Amount:',
              '₱${widget.order.totalPrice + widget.order.deliveryCharge}'),
          const SizedBox(height: 8),
          _buildOrderDetailRow(
              'Credit Available:', '₱${widget.loggedInUser!.creditBalance}'),
          const SizedBox(height: 8),
          _buildOrderDetailRow(
              'Credit After:', '₱${remainingBalance.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildOrderDetailRow('Contact Number:', widget.order.phoneNumber),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return const Column(
      children: [
        Text(
          'By proceeding, you agree to the following:',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          '- You are authorizing payment using your credit card account.',
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          '- Your payment is subject to Visa and Mastercard terms and conditions.',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  void _startPaymentProcessing() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        isLoading = false;
      });

      Navigator.pop(context);
      _showPaymentSuccessDialog(context);
    });
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    FirestoreDatabase firestore = FirestoreDatabase();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 16),
              Text(
                'Your payment was successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                firestore.updatePayment(widget.order.orderId, 'paid', '');
                double newCredit = widget.loggedInUser!.creditBalance -
                    widget.order.totalPrice -
                    widget.order.deliveryCharge;
                firestore.updateCredit(
                    widget.loggedInUser!.uid, newCredit, 'credit-card');

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setDouble('user_credit', newCredit);

                widget.loggedInUser!.creditBalance = newCredit;
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
