class CategoryModel {
  String name;
  String id;

  CategoryModel({required this.name, required this.id});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
