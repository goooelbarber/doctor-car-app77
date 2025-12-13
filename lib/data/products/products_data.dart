import '../../models/product_model.dart';

List<ProductModel> allProducts = [
  ProductModel(
    id: 1,
    brandId: 1,
    carModelId: 1,
    categoryId: 1,
    name: "Toyota Corolla Oil Filter",
    description: "High quality oil filter for Toyota Corolla.",
    price: 120.0,
    imageUrl:
        "https://images.pexels.com/photos/4489744/pexels-photo-4489744.jpeg",
    oemNumber: "90915-10003",
    inStock: true,
  ),
  ProductModel(
    id: 2,
    brandId: 7,
    carModelId: 28,
    categoryId: 1,
    name: "Audi A3 Air Filter",
    description: "OEM air filter for Audi A3 engines.",
    price: 180.0,
    imageUrl:
        "https://images.pexels.com/photos/4489746/pexels-photo-4489746.jpeg",
    oemNumber: "1K0129620",
    inStock: true,
  ),
  ProductModel(
    id: 3,
    brandId: 6,
    carModelId: 23,
    categoryId: 1,
    name: "BMW Oil Pump",
    description: "High performance oil pump for BMW engines.",
    price: 900.0,
    imageUrl:
        "https://images.pexels.com/photos/4489748/pexels-photo-4489748.jpeg",
    oemNumber: "11417501566",
    inStock: true,
  ),
];
