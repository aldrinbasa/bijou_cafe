import 'package:bijou_cafe/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:bijou_cafe/models/product_model.dart';
import 'package:bijou_cafe/constants/colors.dart';

class ProductDetailModal extends StatefulWidget {
  final ProductModel product;

  const ProductDetailModal({Key? key, required this.product}) : super(key: key);

  @override
  ProductDetailModalState createState() => ProductDetailModalState();
}

class ProductDetailModalState extends State<ProductDetailModal> {
  late Variant selectedVariant;
  int numberOfOrder = 1;
  List<int> addOnQuantities = [];

  @override
  void initState() {
    super.initState();
    selectedVariant = widget.product.variation.first;
    addOnQuantities = List<int>.filled(widget.product.addOns.length, 0);
  }

  double calculateTotalPrice() {
    double variantPrice = selectedVariant.price * numberOfOrder;
    double addOnsTotal = 0;
    for (int i = 0; i < widget.product.addOns.length; i++) {
      addOnsTotal += widget.product.addOns[i].price * addOnQuantities[i];
    }
    return variantPrice + (addOnsTotal * numberOfOrder);
  }

  void addItemToCart(OrderModel order) {
    setState(() {
      CartSingleton().addToCart(order);
      CartSingleton().onCartUpdated.call(CartSingleton().getCartItemCount());
    });
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (numberOfOrder > 1) {
                                      setState(() {
                                        numberOfOrder--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle),
                                ),
                                Text(
                                  numberOfOrder.toString(),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black87),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (numberOfOrder < 10) {
                                      setState(() {
                                        numberOfOrder++;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                        Text(
                          (selectedVariant.stock > 0)
                              ? "Stock: ${selectedVariant.stock}"
                              : "Not Available",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        AddOnsList(
                          addOns: widget.product.addOns,
                          quantities: addOnQuantities,
                          onQuantityChanged: (int index, int quantity) {
                            setState(() {
                              addOnQuantities[index] = quantity;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₱ ${calculateTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (selectedVariant.stock > 0)
                          ? () {
                              String notes = "";

                              for (int i = 0;
                                  i < widget.product.addOns.length;
                                  i++) {
                                if (addOnQuantities[i] > 0) {
                                  notes =
                                      "$notes ${widget.product.addOns[i].item} (x${addOnQuantities[i]})\n";
                                }
                              }

                              OrderModel order = OrderModel(
                                productName: widget.product.name,
                                notes: notes.trimRight(),
                                quantity: numberOfOrder,
                                totalPrice: calculateTotalPrice(),
                                variant: (selectedVariant.variant.isNotEmpty)
                                    ? selectedVariant.variant
                                    : "Single Order",
                                imagePath: widget.product.imagePath,
                              );

                              addItemToCart(order);
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        backgroundColor: (selectedVariant.stock > 0)
                            ? primaryColor
                            : Colors.grey,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Add To Cart',
                              style: TextStyle(color: Colors.white)),
                        ],
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

class AddOnsList extends StatelessWidget {
  final List<AddOn> addOns;
  final List<int> quantities;
  final void Function(int, int) onQuantityChanged;

  const AddOnsList({
    super.key,
    required this.addOns,
    required this.quantities,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (addOns.isNotEmpty) {
      return Column(
        children: [
          const Text(
            "Add Ons",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: addOns.length,
            itemBuilder: (context, index) {
              final addOn = addOns[index];
              final quantity = quantities[index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₱${addOn.price.toStringAsFixed(2)} - ${addOn.item}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 0) {
                            onQuantityChanged(index, quantity - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          onQuantityChanged(index, quantity + 1);
                        },
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      );
    } else {
      return const SizedBox(
        height: 1,
      );
    }
  }
}
