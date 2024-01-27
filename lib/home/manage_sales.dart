import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/order_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/constants/colors.dart';

class ManageSales extends StatefulWidget {
  const ManageSales({Key? key}) : super(key: key);

  @override
  State<ManageSales> createState() => ManageSalesState();
}

class ManageSalesState extends State<ManageSales> {
  FirestoreDatabase firestore = FirestoreDatabase();
  late List<OnlineOrderModel> refreshedOrders;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;

  List<OnlineOrderModel> orders = [];

  @override
  void initState() {
    super.initState();
    _getInitialOrders();
  }

  Future<void> _getInitialOrders() async {
    List<OnlineOrderModel>? initialOrders = await firestore.getAllOrder("");
    if (initialOrders != null) {
      setState(() {
        refreshedOrders = initialOrders;
      });
    }
  }

  Future<void> _searchSales() async {
    if (_selectedDateFrom != null && _selectedDateTo != null) {
      setState(() {
        orders = refreshedOrders
            .where((order) =>
                order.dateOrdered.isAfter(_selectedDateFrom!) &&
                order.dateOrdered.isBefore(_selectedDateTo!))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sales',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Colors.black,
                                colorScheme: const ColorScheme.light(
                                    primary: Colors.black),
                                buttonTheme: const ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null &&
                            pickedDate != _selectedDateFrom) {
                          setState(() {
                            _selectedDateFrom = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateFrom == null
                                  ? 'Select Date From'
                                  : 'From: ${DateFormat('yyyy-MM-dd').format(_selectedDateFrom!)}',
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Colors.black,
                                colorScheme: const ColorScheme.light(
                                    primary: Colors.black),
                                buttonTheme: const ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null &&
                            pickedDate != _selectedDateTo) {
                          setState(() {
                            _selectedDateTo = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateTo == null
                                  ? 'Select Date To'
                                  : 'To: ${DateFormat('yyyy-MM-dd').format(_selectedDateTo!)}',
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        OnlineOrderModel order = orders[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Order ID: ${order.orderId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(order.dateOrdered)}'),
                                Text(
                                    'Total Price: ${order.totalPrice.toString()}'),
                                Text(
                                    'Delivery Charge: ${order.deliveryCharge.toString()}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total Sales: ${_calculateTotalSales().toString()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Top 3 Selling Items:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTopSellingItems(),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _searchSales();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems() {
    Map<String, int> productCountMap = {};

    for (OnlineOrderModel order in orders) {
      for (OrderModel orderItem in order.orders) {
        String productKey = '${orderItem.productName} - ${orderItem.variant}';
        productCountMap.update(
            productKey, (value) => value + orderItem.quantity,
            ifAbsent: () => orderItem.quantity);
      }
    }

    List<MapEntry<String, int>> sortedProducts = productCountMap.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<Widget> topSellingItems = [];
    for (int i = 0; i < sortedProducts.length && i < 3; i++) {
      String productKey = sortedProducts[i].key;
      List<String> productInfo = productKey.split(' - ');

      topSellingItems.add(
        Column(
          children: [
            Text(
              '${productInfo[0]} - ${productInfo[1]}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Quantity Sold: ${sortedProducts[i].value}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return Column(children: topSellingItems);
  }

  double _calculateTotalSales() {
    double totalSales = 0;
    for (OnlineOrderModel order in orders) {
      totalSales += order.totalPrice;
    }
    return totalSales;
  }
}
