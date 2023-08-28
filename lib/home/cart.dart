import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/models/order_model.dart';
import 'package:flutter/material.dart';

class CartDetailsWidget extends StatefulWidget {
  const CartDetailsWidget({Key? key}) : super(key: key);

  @override
  CartDetailsWidgetState createState() => CartDetailsWidgetState();
}

class CartDetailsWidgetState extends State<CartDetailsWidget> {
  bool isCartEmpty = false;

  @override
  void initState() {
    super.initState();
    isCartEmpty = CartSingleton().getCartItemCount() == 0;
  }

  void _updateCartItemCount() {
    setState(() {
      isCartEmpty = CartSingleton().getCartItemCount() == 0;
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final order in CartSingleton().orders)
                            OrderItem(
                              order: order,
                              onUpdate: _updateCartItemCount,
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!isCartEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      ElevatedButton(
                        onPressed: () {},
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
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                            double pricePerOrder =
                                widget.order.totalPrice / widget.order.quantity;
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
    );
  }
}
