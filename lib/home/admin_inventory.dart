import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:bijou_cafe/models/product_model.dart';
import 'package:bijou_cafe/constants/colors.dart';

class AdminInventory extends StatefulWidget {
  final ProductModel product;

  const AdminInventory({Key? key, required this.product}) : super(key: key);

  @override
  AdminInventoryState createState() => AdminInventoryState();
}

class AdminInventoryState extends State<AdminInventory> {
  late Variant selectedVariant;
  TextEditingController stockController = TextEditingController();
  int numberOfOrder = 1;
  List<int> addOnQuantities = [];
  FirestoreDatabase firestore = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    selectedVariant = widget.product.variation.first;
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.imagePath,
                            fit: BoxFit.cover,
                            height: 300,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.product.description,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: widget.product.variation.map((variation) {
                            final isSelected =
                                variation.variant == selectedVariant.variant;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVariant = variation;
                                });
                              },
                              child: Chip(
                                label: Text(
                                  variation.variant.isEmpty
                                      ? 'Single Order'
                                      : variation.variant,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                backgroundColor:
                                    isSelected ? primaryColor : Colors.grey,
                              ),
                            );
                          }).toList(),
                        ),
                        GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Enter Stock Quantity'),
                                  content: TextFormField(
                                    controller: stockController,
                                    keyboardType: TextInputType.number,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        int enteredQuantity =
                                            int.parse(stockController.text);
                                        await firestore.updateProductStock(
                                            widget.product,
                                            selectedVariant.variant,
                                            enteredQuantity);
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            (selectedVariant.stock > 0)
                                ? "Stock: ${selectedVariant.stock}"
                                : "Not Available",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
