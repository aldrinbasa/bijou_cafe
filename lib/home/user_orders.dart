import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserOrders extends StatefulWidget {
  const UserOrders({super.key});

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  late Future<List<OnlineOrderModel>?> ordersFuture;
  final UserModel? loggedInUser = UserSingleton().user;
  FirestoreDatabase firestore = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    ordersFuture = firestore.getAllOrder(loggedInUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Orders",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      FutureBuilder<List<OnlineOrderModel>?>(
                        future: ordersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                              child: Text(
                                  'Error loading orders. Please try again later.'),
                            );
                          } else {
                            List<OnlineOrderModel> orders = snapshot.data!;

                            return Expanded(
                              child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: OrderCard(order: orders[index]),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OnlineOrderModel order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  LinearGradient getStatusGradient(String status) {
    if (status.toLowerCase() == 'pending') {
      return const LinearGradient(
        colors: [Colors.orange, Colors.red],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (status.toLowerCase() == 'accepted') {
      return const LinearGradient(
        colors: [Colors.blue, Colors.green],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (status.toLowerCase() == 'for delivery') {
      return const LinearGradient(
        colors: [Colors.yellow, Colors.deepOrange],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (status.toLowerCase() == 'completed') {
      return const LinearGradient(
        colors: [Colors.green, Colors.lightGreen],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      return const LinearGradient(
        colors: [Colors.black, Colors.black],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.orderId}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat("MMM d, y (h:mm a)").format(order.dateOrdered),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Delivery Address:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              order.address,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phone Number:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              order.phoneNumber,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Delivery Charge: ₱${order.deliveryCharge.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              'Orders: ₱${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              'Total: ₱${(order.totalPrice + order.deliveryCharge).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            Row(
              children: [
                Text(
                  order.payment.paymentMethod,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: getStatusGradient(order.payment.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.payment.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              height: 40,
              constraints: const BoxConstraints(minWidth: 800.0),
              decoration: BoxDecoration(
                gradient: getStatusGradient(order.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Order: ${order.status.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
