import 'package:bijou_cafe/models/category_model.dart';

class ProductModel {
  String id;
  CategoryModel category;
  String description;
  String imagePath;
  String name;
  List<Variant> variation;
  List<AddOn> addOns;

  ProductModel({
    required this.id,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.name,
    required this.variation,
    required this.addOns,
  });

  Map<String, dynamic> toMap(int addOnsId) {
    List<Map<String, dynamic>> variationsList =
        variation.map((v) => v.toMap()).toList();

    Map<String, dynamic> productMap = {
      'categoryId': category.id,
      'description': description,
      'imagePath': imagePath,
      'name': name,
    };

    if (variationsList.length > 1) {
      productMap['variations'] = variationsList;
    } else {
      variation[0].variant = '';
      productMap['variations'] = [
        {
          'variant': '',
          'price': variation[0].price,
          'stock': variation[0].stock
        }
      ];
    }

    if (addOnsId > 0) {
      productMap['addOnsId'] = addOnsId;
    }

    return productMap;
  }
}

class Variant {
  double price;
  String variant;
  int stock;

  Variant({required this.price, required this.variant, required this.stock});

  Map<String, dynamic> toMap() {
    return {'price': price, 'variant': variant, 'stock': stock};
  }
}

class AddOn {
  String item;
  double price;

  AddOn({
    required this.item,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {'item': item, 'price': price};
  }
}
