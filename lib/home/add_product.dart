// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/constants/sizes.dart';
import 'package:bijou_cafe/models/add_on_database.dart';
import 'package:bijou_cafe/models/category_model.dart';
import 'package:bijou_cafe/models/product_model.dart';
import 'package:bijou_cafe/utils/firebase_storage.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  AddOnModel? _selectedAddOn;
  CategoryModel? _selectedCategory;
  List<Variant> variants = [];
  File? _selectedImage;

  bool _isLoading = false;

  late Future<List<CategoryModel>?> categories;
  late Future<List<AddOnModel>?> addOns;

  FirestoreDatabase firestore = FirestoreDatabase();
  FireBaseStorageService storage = FireBaseStorageService();

  Future<void> _uploadProduct(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (nameController.text.isEmpty) {
        Toast.show(context, 'Product Name is required!');
      } else if (descriptionController.text.isEmpty) {
        Toast.show(context, 'Product Description is required!');
      } else if (_selectedCategory == null) {
        Toast.show(context, 'Please select a category.');
      } else if (variants.isEmpty) {
        Toast.show(context, 'At least one(1) variant is needed');
      } else if (_selectedImage == null) {
        Toast.show(context, 'Please select a photo.');
      } else {
        String imagePath =
            await storage.uploadProductImageAndGetURL(_selectedImage!);

        ProductModel product = ProductModel(
            id: '',
            category: _selectedCategory!,
            description: descriptionController.text,
            imagePath: imagePath,
            name: nameController.text,
            variation: variants,
            addOns: []);

        await firestore.createProduct(
            product, (_selectedAddOn != null) ? _selectedAddOn!.id : 0);

        Toast.show(context, '${nameController.text} has been added!');
      }
    } catch (e) {
      // print(e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    categories = firestore.getAllCategories();
    addOns = firestore.getAllAddOns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(formHeight - 10),
        padding: const EdgeInsets.symmetric(vertical: formHeight - 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.coffee,
                    color: primaryColor,
                  ),
                  labelText: 'Product Name',
                  hintText: 'Cafe Americano',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  labelStyle: TextStyle(
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: formHeight / 2),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.description,
                    color: primaryColor,
                  ),
                  labelText: 'Description',
                  hintText: 'Strong black coffee with hot...',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  labelStyle: TextStyle(
                    color: primaryColor,
                  ),
                ),
              ),
              FutureBuilder<List<CategoryModel>?>(
                future: categories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading categories');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No categories available');
                  } else {
                    final categoryList = snapshot.data!;
                    return SizedBox(
                        height: 50, child: buildCategoryChips(categoryList));
                  }
                },
              ),
              FutureBuilder<List<AddOnModel>?>(
                future: addOns,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading addons');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No addons available');
                  } else {
                    final addons = snapshot.data!;
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: DropdownButtonFormField<AddOnModel>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Add Ons',
                                    hintStyle: TextStyle(color: primaryColor),
                                    border: InputBorder.none,
                                  ),
                                  value: _selectedAddOn,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedAddOn = newValue;
                                    });
                                  },
                                  items: [
                                    const DropdownMenuItem<AddOnModel>(
                                      value: null,
                                      child: Text(
                                        'None',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    ...addons.map((addon) {
                                      return DropdownMenuItem<AddOnModel>(
                                        value: addon,
                                        child: Text(
                                          addon.addOns
                                              .map((addon) => addon.item)
                                              .join(', '),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: formHeight / 2),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: () async {
                    TextEditingController variantController =
                        TextEditingController();
                    TextEditingController priceController =
                        TextEditingController();
                    TextEditingController stockController =
                        TextEditingController();

                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Add Variant"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                controller: variantController,
                                decoration: const InputDecoration(
                                  hintText: "Name",
                                ),
                              ),
                              TextFormField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                  hintText: "Price",
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: stockController,
                                decoration: const InputDecoration(
                                  hintText: "Stock",
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                if (priceController.text.isNotEmpty ||
                                    variantController.text.isNotEmpty ||
                                    stockController.text.isNotEmpty) {
                                  Variant variant = Variant(
                                    price: double.parse(priceController.text),
                                    variant: variantController.text,
                                    stock: int.parse(stockController.text),
                                  );

                                  setState(() {
                                    variants.add(variant);
                                  });
                                }

                                Navigator.of(context).pop();
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.local_pizza),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const Text(
                            'Add Variants',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              (variants.isNotEmpty)
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 175),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: variants.length,
                        itemBuilder: (BuildContext context, int index) {
                          Variant variant = variants[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            title: Text(
                              '₱${variant.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              variant.variant,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  variants.removeWhere((element) =>
                                      element.variant == variant.variant);
                                });
                              },
                              icon: const Icon(Icons.remove),
                              label: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(height: 0),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                height: 60,
                child: GestureDetector(
                  onTap: () async {
                    final imagePicker = ImagePicker();
                    final pickedImage = await showModalBottomSheet<PickedFile>(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Gallery'),
                                onTap: () async {
                                  final xFile = await imagePicker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (xFile != null) {
                                    Navigator.pop(
                                        context, PickedFile(xFile.path));
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Camera'),
                                onTap: () async {
                                  final xFile = await imagePicker.pickImage(
                                    source: ImageSource.camera,
                                  );
                                  if (xFile != null) {
                                    Navigator.pop(
                                        context, PickedFile(xFile.path));
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (pickedImage != null) {
                      setState(() {
                        _selectedImage = File(pickedImage.path);
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.photo),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const Text(
                            'Select Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/placeholder.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.scaleDown,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: formHeight),
              SizedBox(
                height: buttonPrimaryHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _uploadProduct(context),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('UPLOAD'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryChips(List<CategoryModel> categories) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory != null &&
            category.name == _selectedCategory!.name;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : category;
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
}
