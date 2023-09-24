class OrderModel {
  String productName;
  String variant;
  String notes;
  String imagePath;
  int quantity;
  double totalPrice;

  OrderModel(
      {required this.productName,
      required this.notes,
      required this.quantity,
      required this.totalPrice,
      required this.variant,
      required this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'variant': variant,
      'notes': notes,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'imagePath': imagePath
    };
  }
}

class CartSingleton {
  static final CartSingleton _instance = CartSingleton._internal();

  factory CartSingleton() {
    return _instance;
  }

  CartSingleton._internal();

  List<OrderModel> orders = [];

  void addToCart(OrderModel item) {
    bool itemExists = false;
    for (OrderModel order in orders) {
      if ((order.productName == item.productName) &&
          (order.notes == item.notes) &&
          (order.variant == item.variant)) {
        order.quantity = order.quantity + item.quantity;
        order.totalPrice = order.totalPrice + item.totalPrice;
        itemExists = true;
        break;
      }
    }
    if (!itemExists) {
      orders.add(item);
    }
  }

  void removeFromCart(OrderModel item) {
    orders.removeWhere((cartItem) =>
        (cartItem.productName == item.productName) &&
        (cartItem.notes == item.notes) &&
        (cartItem.variant == item.variant));
  }

  int getCartItemCount() {
    return orders.length;
  }

  void clearCart() {
    orders.clear();
    onCartUpdated(0);
  }

  late Function(int) onCartUpdated;

  void setCartUpdatedCallback(Function(int) callback) {
    onCartUpdated = callback;
  }
}
