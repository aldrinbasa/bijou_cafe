import 'package:bijou_cafe/models/order_model.dart';

class OnlineOrderModel {
  String orderId;
  String address;
  double deliveryCharge;
  List<OrderModel> orders;
  PaymentModel payment;
  String phoneNumber;
  String status;
  double totalPrice = 0;
  String userID;
  DateTime dateOrdered = DateTime.now();

  OnlineOrderModel(
      {required this.address,
      required this.deliveryCharge,
      required this.orders,
      required this.payment,
      required this.phoneNumber,
      required this.status,
      required this.userID,
      required this.orderId,
      required this.dateOrdered}) {
    for (int i = 0; i < orders.length; i++) {
      totalPrice = totalPrice + orders[i].totalPrice;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'deliveryCharge': deliveryCharge,
      'items': orders.map((order) => order.toMap()).toList(),
      'payment': payment.toMap(),
      'phoneNumber': phoneNumber,
      'status': status,
      'totalPrice': totalPrice,
      'userID': userID,
      'dateOrdered': dateOrdered
    };
  }
}

class PaymentModel {
  String paymentMethod;
  String status;
  String referenceId;

  PaymentModel(
      {required this.paymentMethod,
      required this.status,
      required this.referenceId});

  Map<String, dynamic> toMap() {
    return {
      'method': paymentMethod,
      'status': status,
    };
  }
}
