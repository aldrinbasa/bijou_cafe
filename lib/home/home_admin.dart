import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/home/home_user_screen.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirestoreDatabase firestore = FirestoreDatabase();
  final UserModel? loggedInUser = UserSingleton().user;

  Future<void> _refreshData() async {
    List<OnlineOrderModel>? refreshedOrders = await firestore.getAllOrder('');

    if (refreshedOrders != null) {
      setState(() {
        orders = refreshedOrders;
      });
    }
  }

  List<OnlineOrderModel> orders = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        drawer: ClientDrawer(),
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Center(
            child: Text(
              'Bijou Cafe (Admin)',
              style: TextStyle(color: primaryColor),
            ),
          ),
          backgroundColor: secondaryColor,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.access_alarm_outlined,
                  color: primaryColor,
                ))
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return CustomOrderCard(order: orders[index]);
            },
          ),
        ),
      ),
    );
  }
}

class CustomOrderCard extends StatelessWidget {
  final OnlineOrderModel order;

  const CustomOrderCard({Key? key, required this.order}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'for delivery':
        return Colors.yellow;
      case 'completed':
        return Colors.green;
      case 'paid':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy (h:mm a)').format(dateTime);
  }

  String _formatPrice(double price) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );
    return currencyFormatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order ID: ${order.orderId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'Address:',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              order.address,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Price:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      _formatPrice(order.totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date Ordered:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      _formatDate(order.dateOrdered),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white),
            Row(
              children: [
                const Text(
                  'Payment:',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  order.payment.paymentMethod,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Charge:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      _formatPrice(order.deliveryCharge),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Chip(
                    label: Text(
                      order.payment.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _getStatusColor(order.payment.status),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white),
            Align(
              alignment: Alignment.center,
              child: Chip(
                elevation: 2,
                label: Text(
                  "Order Status: ${order.status.toUpperCase()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(order.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
