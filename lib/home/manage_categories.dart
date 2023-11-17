// ignore_for_file: use_build_context_synchronously

import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/models/category_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:flutter/material.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({Key? key}) : super(key: key);

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  late Future<List<CategoryModel>?> categoryFuture;
  FirestoreDatabase firestore = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    categoryFuture = firestore.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Manage Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CategoryModel>?>(
                future: categoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error.toString()}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No categories available.'),
                    );
                  } else {
                    final categories = snapshot.data;

                    return ListView.builder(
                      itemCount: categories!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final category = categories[index];
                        return Dismissible(
                          key: Key(category.id.toString()),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              final TextEditingController controller =
                                  TextEditingController();

                              final String? newCategoryName = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Edit ${category.name}"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextFormField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            hintText: "Enter new category name",
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(""),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(controller.text);
                                        },
                                        child: const Text("Save"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (newCategoryName != null &&
                                  newCategoryName != "") {
                                category.name = newCategoryName;
                                await firestore.updateCategoryName(category);
                                setState(() {
                                  categoryFuture = firestore.getAllCategories();
                                });
                              }
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              final bool deleteConfirmed = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Deletion"),
                                    content: const Text(
                                        "Are you sure you want to delete this category?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (deleteConfirmed == true) {
                                try {
                                  int? productCount = await firestore
                                      .getProductCountByCategory(category.id);

                                  if (productCount == 0) {
                                    await firestore.deleteCategory(category);
                                    setState(() {
                                      categoryFuture =
                                          firestore.getAllCategories();
                                    });
                                  } else {
                                    Navigator.of(context).pop();

                                    Toast.show(
                                      context,
                                      "Cannot delete ${category.name} because there are products using the category",
                                    );
                                  }
                                } catch (e) {
                                  Toast.show(
                                    context,
                                    "Error occurred when trying to delete a category.",
                                  );
                                }
                              }
                            }
                            return null;
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(category.name),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final TextEditingController controller =
                    TextEditingController();

                final String? newCategoryName = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Add New Category"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Enter new category name",
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(""),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(controller.text);
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    );
                  },
                );

                if (newCategoryName != null && newCategoryName.isNotEmpty) {
                  await firestore.createCategory(newCategoryName);
                  setState(() {
                    categoryFuture = firestore.getAllCategories();
                  });
                }
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
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Add Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
