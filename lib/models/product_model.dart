import 'package:bijou_cafe/models/category_model.dart';

class ProductModel {
  CategoryModel category;
  String description;
  String imagePath;
  String name;
  List<Variant> variation;

  ProductModel({
    required this.category,
    required this.description,
    required this.imagePath,
    required this.name,
    required this.variation,
  });
}

class Variant {
  double price;
  String variant;

  Variant({
    required this.price,
    required this.variant,
  });
}
