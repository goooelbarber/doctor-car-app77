class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({
    required this.id,
    required this.name,
  });
}

const List<CategoryModel> categories = [
  CategoryModel(id: 1, name: 'فلاتر'),
  CategoryModel(id: 2, name: 'فرامل'),
  CategoryModel(id: 3, name: 'زيوت'),
  CategoryModel(id: 4, name: 'إطارات'),
  CategoryModel(id: 5, name: 'تعليق'),
];
