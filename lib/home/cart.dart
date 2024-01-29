import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/models/voucher_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/utils/notifications.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:flutter/material.dart';

class CartDetailsWidget extends StatefulWidget {
  const CartDetailsWidget({Key? key}) : super(key: key);

  @override
  CartDetailsWidgetState createState() => CartDetailsWidgetState();
}

class CartDetailsWidgetState extends State<CartDetailsWidget> {
  final UserModel? loggedInUser = UserSingleton().user;
  VoucherModel? voucherApplied;
  bool isCartEmpty = false;
  double totalPrice = 0;
  double discountedPrice = 0;
  bool isCheckingOut = false;
  bool paymentMethodSelected = false;
  bool voucherApplicable = false;
  String paymentChoice = "";
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController voucher = TextEditingController();

  FirestoreDatabase firestoreDatabase = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    isCartEmpty = CartSingleton().getCartItemCount() == 0;
    calculateTotalPrice();
  }

  Future<void> processCheckOut() async {
    try {
      if (paymentChoice != "") {
        PaymentModel payment = PaymentModel(
            paymentMethod: paymentChoice, status: "pending", referenceId: '');
        OnlineOrderModel onlineOrder = OnlineOrderModel(
            voucherDiscount:
                (voucherApplied != null) ? voucherApplied!.percentage : 0,
            address: address.text,
            deliveryCharge: 0.0,
            orders: CartSingleton().orders,
            payment: payment,
            phoneNumber: phoneNumber.text,
            status: 'pending',
            userID: loggedInUser!.uid,
            orderId: '',
            dateOrdered: DateTime.now());

        firestoreDatabase.createOrder(onlineOrder);

        Notifications notifications = Notifications();
        await notifications.updateNewOrderNotifValue(true);

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(CartSingleton().getCartItemCount());

        CartSingleton().clearCart();

        // ignore: use_build_context_synchronously
        Toast.show(context,
            "Your order has been received! Wait for shop confirmation");
      } else {
        setState(() {
          paymentMethodSelected = true;
        });
      }
    } catch (e) {
      Toast.show(context, e.toString());
    }
  }

  Widget buildDialogContent() {
    if (isCheckingOut) {
      return Stack(
        children: [
          Container(
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
                  "Checkout",
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
                SingleChildScrollView(
                  child: Column(children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.all(.0),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: primaryColor,
                        ),
                      ),
                      controller: phoneNumber,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Visibility(
                      visible: !paymentMethodSelected,
                      child: const Text(
                        "*Choose a payment method",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    RadioListTile<String>(
                      title: const Text('GCash'),
                      value: 'GCash',
                      groupValue: paymentChoice,
                      onChanged: (value) {
                        setState(() {
                          paymentChoice = value!;
                          paymentMethodSelected = true;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Credit Card'),
                      value: 'CreditCard',
                      groupValue: paymentChoice,
                      onChanged: (value) {
                        setState(() {
                          paymentChoice = value!;
                          paymentMethodSelected = true;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Paypal'),
                      value: 'Paypal',
                      groupValue: paymentChoice,
                      onChanged: (value) {
                        setState(() {
                          paymentChoice = value!;
                          paymentMethodSelected = true;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash On Delivery'),
                      value: 'Cash On Delivery',
                      groupValue: paymentChoice,
                      onChanged: (value) {
                        setState(() {
                          paymentChoice = value!;
                          paymentMethodSelected = true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60.0,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Voucher/Discount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          contentPadding: const EdgeInsets.all(10.0),
                          prefixIcon: const Icon(
                            Icons.discount,
                            color: primaryColor,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () async {
                              String voucherCode = voucher.text;

                              voucherApplied = await firestoreDatabase
                                  .verifyVoucher(voucherCode);

                              if (voucherApplied!.percentage != 0) {
                                setState(() {
                                  voucherApplicable = true;
                                  discountedPrice = totalPrice *
                                      (1 - voucherApplied!.percentage / 100);
                                });
                              } else {
                                setState(() {
                                  discountedPrice = 0;
                                  voucherApplicable = false;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        controller: voucher,
                      ),
                    ),
                    voucherApplicable
                        ? const SizedBox(height: 0)
                        : const Text("Voucher doesn't exist."),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.all(.0),
                        prefixIcon: const Icon(
                          Icons.home,
                          color: primaryColor,
                        ),
                      ),
                      controller: address,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                voucherApplicable
                    ? const SizedBox(width: 0, height: 0)
                    : Text(
                        "₱${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                voucherApplicable
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "(₱${totalPrice.toStringAsFixed(2)})",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            " ₱${discountedPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      )
                    : const SizedBox(width: 0, height: 0),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (voucherApplied != null) {
                      if (voucherApplied!.percentage != 0) {
                        firestoreDatabase.useVoucher(voucherApplied!);
                      }
                    }
                    processCheckOut();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              onPressed: () {
                setState(() {
                  isCheckingOut = false;
                });
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cart",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Image.asset(
              'assets/shopping.gif',
              height: 150,
              width: double.infinity,
            ),
            if (isCartEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: SingleChildScrollView(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 16.0);
                    },
                    itemCount: CartSingleton().orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      final order = CartSingleton().orders[index];
                      return OrderItem(
                        order: order,
                        onUpdate: _updateCartItemCount,
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (!isCartEmpty)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "₱${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          CartSingleton().clearCart();
                          _updateCartItemCount();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Clear Cart'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isCheckingOut = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          backgroundColor: primaryColor,
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      );
    }
  }

  void calculateTotalPrice() {
    double total = 0.0;
    for (final order in CartSingleton().orders) {
      total += order.totalPrice;
    }
    setState(() {
      totalPrice = total;
    });
  }

  void _updateCartItemCount() {
    setState(() {
      isCartEmpty = CartSingleton().getCartItemCount() == 0;
      calculateTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(CartSingleton().getCartItemCount());
      },
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: buildDialogContent(),
        ),
      ),
    );
  }
}

class OrderItem extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onUpdate;

  const OrderItem({Key? key, required this.order, required this.onUpdate})
      : super(key: key);

  @override
  OrderItemState createState() => OrderItemState();
}

class OrderItemState extends State<OrderItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(widget.order.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    widget.order.variant,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (widget.order.notes.isNotEmpty)
                    Text(
                      widget.order.notes,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (widget.order.quantity > 1) {
                              double pricePerOrder = widget.order.totalPrice /
                                  widget.order.quantity;
                              widget.order.quantity--;
                              widget.order.totalPrice =
                                  pricePerOrder * widget.order.quantity;
                            }
                          });
                          widget.onUpdate();
                        },
                        icon: const Icon(Icons.remove_circle),
                      ),
                      Text(
                        widget.order.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            double pricePerOrder =
                                widget.order.totalPrice / widget.order.quantity;
                            widget.order.quantity++;
                            widget.order.totalPrice =
                                pricePerOrder * widget.order.quantity;
                          });
                          widget.onUpdate();
                        },
                        icon: const Icon(Icons.add_circle),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            CartSingleton().removeFromCart(widget.order);
                          });
                          widget.onUpdate();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size(100, 30),
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₱${widget.order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartContent extends StatelessWidget {
  const CartContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
