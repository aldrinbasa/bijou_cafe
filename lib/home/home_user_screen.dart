import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bijou_cafe/home/admin_past_orders.dart';
import 'package:bijou_cafe/home/cart.dart';
import 'package:bijou_cafe/home/manage_categories.dart';
import 'package:bijou_cafe/home/manage_sales.dart';
import 'package:bijou_cafe/home/user_orders.dart';
import 'package:bijou_cafe/init/login/login_controller.dart';
import 'package:bijou_cafe/models/order_model.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/notifications.dart';
import 'package:flutter/material.dart';
import 'package:bijou_cafe/models/category_model.dart';
import 'package:bijou_cafe/models/product_model.dart';
import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/home/product_tile.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({Key? key}) : super(key: key);

  @override
  HomeUserScreenState createState() => HomeUserScreenState();
}

class HomeUserScreenState extends State<HomeUserScreen> {
  final UserModel? loggedInUser = UserSingleton().user;
  late Future<List<ProductModel>?> productsFuture;
  late Future<List<CategoryModel>?> categoryFuture;
  FirestoreDatabase firestore = FirestoreDatabase();
  String searchQuery = '';
  bool showCategories = false;
  String selectedCategory = '';
  int cartItemCount = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    productsFuture = firestore.getAllProducts();
    categoryFuture = firestore.getAllCategories();
    CartSingleton().setCartUpdatedCallback(updateCartCount);

    Notifications notifications = Notifications();
    notifications.listenToUserNotif(loggedInUser!.uid);
    notifications.newStatusStream.listen((data) {
      if (bool.parse(data['notify'].toString()) &&
          loggedInUser!.userType != "admin") {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "basic_channel",
            title: "Your Order Was Updated",
            body:
                "Hi  ${loggedInUser!.firstName}! Your order has been updated to ${data['process'].toString().toUpperCase()}",
          ),
        );
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      productsFuture = firestore.getAllProducts();
      categoryFuture = firestore.getAllCategories();
      CartSingleton().setCartUpdatedCallback(updateCartCount);
    });
  }

  void updateCartCount(int itemCount) {
    setState(() {
      cartItemCount = itemCount;
    });
  }

  List<ProductModel> filterProducts(List<ProductModel> products) {
    if (searchQuery.isEmpty) {
      return products;
    } else {
      return products
          .where((product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  Widget buildCategoryChips(List<CategoryModel> categories) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.name == selectedCategory;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = isSelected ? '' : category.name;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(category.name),
              backgroundColor: isSelected ? primaryColor : secondaryColor,
              labelStyle: TextStyle(
                color: isSelected ? secondaryColor : primaryColor,
              ),
              side: const BorderSide(color: primaryColor),
            ),
          ),
        );
      },
    );
  }

  Widget buildProductGrid(List<ProductModel> products) {
    final filteredProducts = selectedCategory.isEmpty
        ? filterProducts(products)
        : products
            .where((product) => product.category.name == selectedCategory)
            .toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductTile(product: filteredProducts[index]);
      },
    );
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
        key: _scaffoldKey,
        drawer: ClientDrawer(),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Center(
            child: Text(
              'Bijou Cafe',
              style: TextStyle(color: primaryColor),
            ),
          ),
          backgroundColor: secondaryColor,
          elevation: 0,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: primaryColor,
                  ),
                  onPressed: () async {
                    final updatedCartCount = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return const CartDetailsWidget();
                      },
                    );

                    if (updatedCartCount != null) {
                      setState(() {
                        cartItemCount = updatedCartCount;
                      });
                    }
                  },
                ),
                if (CartSingleton().getCartItemCount() > 0)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        cartItemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 8,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Find what you\'re craving for',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.all(.0),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        setState(() {
                          showCategories = !showCategories;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (showCategories)
              SizedBox(
                height: 48.0,
                child: FutureBuilder<List<CategoryModel>?>(
                  future: categoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text('Error loading categories'),
                      );
                    } else {
                      return buildCategoryChips(snapshot.data!);
                    }
                  },
                ),
              )
            else
              const SizedBox(width: 1),
            Expanded(
              flex: 10,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: FutureBuilder<List<ProductModel>?>(
                  future: productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text('Error loading products'),
                      );
                    } else {
                      final filteredProducts = filterProducts(snapshot.data!);
                      return buildProductGrid(filteredProducts);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientDrawer extends StatelessWidget {
  final UserModel? loggedInUser = UserSingleton().user;
  final LoginController loginController = LoginController();

  ClientDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            height: 120,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cafe_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${loggedInUser!.firstName} ${loggedInUser!.lastName}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    loggedInUser!.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: secondaryColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  (loggedInUser!.userType == 'admin')
                      ? ListTile(
                          leading: const Icon(Icons.book),
                          title: const Text("Past Orders"),
                          onTap: () async {
                            Navigator.pop(context);
                            await showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                return const AdminPastOrders();
                              },
                            );
                          },
                        )
                      : ListTile(
                          leading: const Icon(Icons.book),
                          title: const Text("Orders"),
                          onTap: () async {
                            Navigator.pop(context);
                            await showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                if (loggedInUser!.userType == 'admin') {
                                  return const Text("data");
                                } else {
                                  return const UserOrders();
                                }
                              },
                            );
                          },
                        ),
                  (loggedInUser!.userType == 'admin')
                      ? ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Categories'),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const ManageCategories();
                              },
                            );
                          },
                        )
                      : const SizedBox(height: 0),
                  (loggedInUser!.userType == 'admin')
                      ? ListTile(
                          leading: const Icon(Icons.wallet),
                          title: const Text('Sales'),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const ManageSales();
                              },
                            );
                          },
                        )
                      : const SizedBox(height: 0),
                  (loggedInUser!.userType == 'admin')
                      ? ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('Inventory'),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const ManageSales();
                              },
                            );
                          },
                        )
                      : const SizedBox(height: 0),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showLogoutConfirmationDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    loginController.logout(context);
  }
}
