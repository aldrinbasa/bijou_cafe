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
  late Future<List<ProductModel>?> productsFuture;
  late Future<List<CategoryModel>?> categoryFuture;
  FirestoreDatabase firestore = FirestoreDatabase();
  String searchQuery = '';
  bool showCategories = false;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    productsFuture = firestore.getAllProducts();
    categoryFuture = firestore.getAllCategories();
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryColor),
          onPressed: () {},
        ),
        title: const Center(
          child: Text(
            'Cafe Bijou',
            style: TextStyle(color: primaryColor),
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: primaryColor,
            ),
            onPressed: () {},
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
              height: 48.0, // Adjust the height as needed
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
            const SizedBox(width: 1), // Use width instead of height
          Expanded(
            flex: 10,
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
        ],
      ),
    );
  }
}
