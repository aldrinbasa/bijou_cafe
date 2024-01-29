import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/constants/texts.dart';
import 'package:bijou_cafe/home/credit_checkout.dart';
import 'package:bijou_cafe/home/paypal_checkout.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _refreshData() async {
    setState(() {
      ordersFuture = firestore.getAllOrder(loggedInUser!.uid);
    });
  }

  Future<void> _deleteOrder(String orderId) async {
    bool confirmDelete = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                confirmDelete = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await firestore.deleteOrder(orderId);
      _refreshData();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
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
                              child: RefreshIndicator(
                                onRefresh: _refreshData,
                                child: ListView.builder(
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onLongPress: () {
                                        _deleteOrder(orders[index].orderId);
                                      },
                                      title: OrderCard(
                                        order: orders[index],
                                        onRefresh: () {
                                          _refreshData();
                                        },
                                      ),
                                    );
                                  },
                                ),
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

class OrderCard extends StatefulWidget {
  final OnlineOrderModel order;
  final Function() onRefresh;

  const OrderCard({Key? key, required this.order, required this.onRefresh})
      : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  FirestoreDatabase firestore = FirestoreDatabase();

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

  void processPaymentUpdate() {
    TextEditingController referenceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Reference ID"),
          content: TextFormField(
            controller: referenceIdController,
            decoration: const InputDecoration(
              labelText: "Reference ID",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                String referenceId = referenceIdController.text;

                firestore.updatePayment(
                    widget.order.orderId, 'paid', referenceId);

                Navigator.of(context).pop();
                widget.onRefresh();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.order.payment.paymentMethod.toLowerCase() == 'paypal' &&
              widget.order.status.toLowerCase() == 'accepted') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return PayPalCheckoutDialog(
                  order: widget.order,
                );
              },
            );
          } else if (widget.order.payment.paymentMethod.toLowerCase() ==
                  'creditcard' &&
              widget.order.status.toLowerCase() == 'accepted') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CrediCheckoutDialog(
                  order: widget.order,
                );
              },
            );
          }
        },
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
                'Order ID: ${widget.order.orderId}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat("MMM d, y (h:mm a)")
                    .format(widget.order.dateOrdered),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delivery Address:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.order.address,
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
                widget.order.phoneNumber,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Delivery Charge: ₱${widget.order.deliveryCharge.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                'Orders: ₱${widget.order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                'Total: ₱${(widget.order.totalPrice + widget.order.deliveryCharge).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.order.payment.paymentMethod,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: getStatusGradient(widget.order.payment.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.order.payment.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              (widget.order.status == 'accepted' &&
                      widget.order.payment.status == 'pending' &&
                      widget.order.payment.paymentMethod == 'GCash')
                  ? Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            processPaymentUpdate();
                          },
                          child: const Text(
                            "Your order has been accepted! Kindly pay the total through GCash and provide the reference number.",
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              gCashNumber,
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: secondaryColor,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  const ClipboardData(text: gCashNumber),
                                );
                                Toast.show(
                                  context,
                                  '$gCashNumber copied to clipboard.',
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                height: 40,
                constraints: const BoxConstraints(minWidth: 800.0),
                decoration: BoxDecoration(
                  gradient: getStatusGradient(widget.order.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Order: ${widget.order.status.toUpperCase()}',
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
      ),
    );
  }
}
