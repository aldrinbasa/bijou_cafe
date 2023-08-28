import 'package:bijou_cafe/models/category_model.dart';

class ProductModel {
  CategoryModel category;
  String description;
  String imagePath;
  String name;
  List<Variant> variation;
  List<AddOn> addOns;

  ProductModel(
      {required this.category,
      required this.description,
      required this.imagePath,
      required this.name,
      required this.variation,
      required this.addOns});
}

class Variant {
  double price;
  String variant;

  Variant({
    required this.price,
    required this.variant,
  });
}

class AddOn {
  String item;
  double price;

  AddOn({required this.item, required this.price});
}
