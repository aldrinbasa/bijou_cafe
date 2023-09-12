import 'package:bijou_cafe/models/category_model.dart';
import 'package:bijou_cafe/models/online_order_model.dart';
import 'package:bijou_cafe/models/order_model.dart';
import 'package:bijou_cafe/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bijou_cafe/models/user_model.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _userCollection = 'users';
  final String _productsCollection = 'products';
  final String _categoryCollection = 'categories';
  final String _addOnsCollection = 'addOns';
  final String _ordersCollection = 'orders';

  Future<Map<String, dynamic>?> getUserInfoByUUID(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(_userCollection)
          .where('uid', isEqualTo: uid)
          .get();

      final userDocument = snapshot.docs.first.data();

      return userDocument;
    } catch (e) {
      return null;
    }
  }

  Future<void> createNewUser(UserModel newUser) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection(_userCollection);

      await usersCollection.doc(newUser.uid).set(newUser.toMap());
    } catch (e) {
      return;
    }
  }

  Future<void> createOrder(OnlineOrderModel onlineOrder) async {
    try {
      CollectionReference orderCollection =
          FirebaseFirestore.instance.collection(_ordersCollection);

      await orderCollection.doc().set(onlineOrder.toMap());
    } catch (e) {
      return;
    }
  }

  Future<List<ProductModel>?> getAllProducts() async {
    try {
      List<ProductModel> products = [];
      final snapshot = await _firestore.collection(_productsCollection).get();
      for (var doc in snapshot.docs) {
        final productData = doc.data();

        List<Variant> variants = [];

        List<dynamic> variationsData = productData['variations'];

        for (var variationData in variationsData) {
          Variant variant = Variant(
              price: double.parse(variationData['price'].toString()),
              variant: variationData['variant'].toString());

          variants.add(variant);
        }

        final categorySnapshot = await _firestore
            .collection(_categoryCollection)
            .where('id',
                isEqualTo: int.parse(productData['categoryId'].toString()))
            .get();
        final categoryData = categorySnapshot.docs.first.data();
        CategoryModel category = CategoryModel(
            name: categoryData['name'],
            id: int.parse(categoryData['id'].toString()));

        List<AddOn> addOns = [];

        if (productData['addOnsId'] != null &&
            productData['addOnsId'].toString().isNotEmpty) {
          final addOnsSnapshot = await _firestore
              .collection(_addOnsCollection)
              .where('id',
                  isEqualTo: int.parse(productData['addOnsId'].toString()))
              .get();

          if (addOnsSnapshot.docs.isNotEmpty) {
            final addOnsList =
                (addOnsSnapshot.docs.first.data()['addOns'] as List<dynamic>)
                    .map((addOn) => AddOn(
                          item: addOn['item'],
                          price: double.parse(addOn['price'].toString()),
                        ))
                    .toList();

            addOns = addOnsList;
          }
        }

        ProductModel product = ProductModel(
            category: category,
            description: productData['description'].toString(),
            imagePath: productData["imagePath"].toString(),
            name: productData['name'].toString(),
            variation: variants,
            addOns: addOns);

        products.add(product);
      }

      return products;
    } catch (e) {
      return null;
    }
  }

  Future<List<CategoryModel>?> getAllCategories() async {
    try {
      List<CategoryModel> categories = [];

      final snapshot = await _firestore.collection(_categoryCollection).get();

      for (var doc in snapshot.docs) {
        final categoryData = doc.data();

        CategoryModel category = CategoryModel(
            name: categoryData['name'].toString(),
            id: int.parse(categoryData['id'].toString()));

        categories.add(category);
      }

      return categories;
    } catch (e) {
      return null;
    }
  }

  Future<List<OnlineOrderModel>?> getAllOrder(String uid) async {
    try {
      List<OnlineOrderModel> orders = [];

      final snapshot = (uid != '')
          ? await _firestore
              .collection(_ordersCollection)
              .where('userID', isEqualTo: uid)
              .orderBy('dateOrdered', descending: true)
              .get()
          : await _firestore
              .collection(_ordersCollection)
              .orderBy('dateOrdered', descending: true)
              .get();

      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        final orderId = doc.id;

        List<OrderModel> items = [];
        List<dynamic> ordersData = orderData['items'];

        for (var orderData in ordersData) {
          OrderModel item = OrderModel(
              productName: orderData['productName'].toString(),
              notes: orderData['notes'],
              quantity: int.parse(orderData['quantity'].toString()),
              totalPrice: double.parse(orderData['totalPrice'].toString()),
              variant: orderData['variant'],
              imagePath: '');

          items.add(item);
        }

        PaymentModel payment = PaymentModel(
            paymentMethod: orderData['payment']['method'],
            status: orderData['payment']['status']);

        OnlineOrderModel order = OnlineOrderModel(
            address: orderData['address'],
            deliveryCharge:
                double.parse(orderData['deliveryCharge'].toString()),
            orders: items,
            payment: payment,
            phoneNumber: orderData['phoneNumber'],
            status: orderData['status'],
            userID: orderData['userID'],
            orderId: orderId,
            dateOrdered: orderData['dateOrdered'].toDate());

        orders.add(order);
      }

      return orders;
    } catch (e) {
      return null;
    }
  }
}
