import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/utils/notifications.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class AdminOrderDetails extends StatefulWidget {
  final OnlineOrderModel order;
  const AdminOrderDetails({super.key, required this.order});

  @override
  State<AdminOrderDetails> createState() => _AdminOrderDetailsState();
}

class _AdminOrderDetailsState extends State<AdminOrderDetails> {
  final UserModel? loggedInUser = UserSingleton().user;
  FirestoreDatabase firestore = FirestoreDatabase();

  void _saveDeliveryCharge() async {
    try {
      firestore.updateOrder(widget.order);

      Navigator.of(context).pop();
      // ignore: empty_catches
    } catch (e) {}
  }

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

  Future<void> _showOrderStatusDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus = widget.order.status;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Order Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('Pending'),
                    value: 'pending',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Accepted'),
                    value: 'accepted',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('For Delivery'),
                    value: 'for delivery',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Completed'),
                    value: 'completed',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Reject'),
                    value: 'rejected',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.order.status = selectedStatus;
                    Navigator.of(context).pop();

                    Notifications notifications = Notifications();
                    notifications.addUserNotif(
                        widget.order.userID, selectedStatus, true);

                    _saveDeliveryCharge();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order #${widget.order.orderId}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.order.orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = widget.order.orders[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: item.imagePath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    (item.notes.isNotEmpty)
                                        ? Text(
                                            item.notes,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const SizedBox(height: 0),
                                    Text(
                                      'Quantity: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Variant: ${item.variant}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Total Price: ₱${item.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 16.0),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DeliveryChargeDialog(
                          onlineOrder: widget.order,
                        );
                      },
                    );
                  },
                  child:
                      Text('Delivery Charge: ₱${widget.order.deliveryCharge}'),
                ),
                GestureDetector(
                  onTap: () {
                    _showOrderStatusDialog(context);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: _getStatusColor(widget.order.status),
                    ),
                    child: Center(
                      child: Text(
                        "Order Status: ${widget.order.status.toUpperCase()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeliveryChargeDialog extends StatefulWidget {
  final OnlineOrderModel onlineOrder;

  const DeliveryChargeDialog({super.key, required this.onlineOrder});

  @override
  DeliveryChargeDialogState createState() => DeliveryChargeDialogState();
}

class DeliveryChargeDialogState extends State<DeliveryChargeDialog> {
  double _deliveryCharge = 0.0;
  FirestoreDatabase firestore = FirestoreDatabase();

  void _incrementCharge() {
    setState(() {
      if (_deliveryCharge + 5 <= 1000) {
        _deliveryCharge += 5;
      }
    });
  }

  void _decrementCharge() {
    setState(() {
      if (_deliveryCharge - 5 >= 0) {
        _deliveryCharge -= 5;
      }
    });
  }

  void _saveDeliveryCharge() async {
    setState(() {
      widget.onlineOrder.deliveryCharge = _deliveryCharge;
    });

    try {
      firestore.updateOrder(widget.onlineOrder);

      Navigator.of(context).pop();
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delivery Charge'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrementCharge,
              ),
              Expanded(
                child: Slider(
                  value: _deliveryCharge,
                  min: 0.0,
                  max: 1000.0,
                  divisions: 100,
                  onChanged: (newValue) {
                    setState(() {
                      _deliveryCharge = newValue;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementCharge,
              ),
            ],
          ),
          Text(
            '₱${_deliveryCharge.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveDeliveryCharge,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
