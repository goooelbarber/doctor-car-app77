import '../../models/car_model.dart';

List<CarModel> carModels = [
  // ---------------------------
  // TOYOTA (BrandId = 1)
  // ---------------------------
  CarModel(id: 1, brandId: 1, modelName: "Corolla", years: [2000, 2024]),
  CarModel(id: 2, brandId: 1, modelName: "Camry", years: [2002, 2024]),
  CarModel(id: 3, brandId: 1, modelName: "Yaris", years: [2000, 2024]),
  CarModel(id: 4, brandId: 1, modelName: "RAV4", years: [2005, 2024]),
  CarModel(id: 5, brandId: 1, modelName: "Hilux", years: [1999, 2024]),

  // ---------------------------
  // NISSAN (BrandId = 2)
  // ---------------------------
  CarModel(id: 6, brandId: 2, modelName: "Altima", years: [2002, 2024]),
  CarModel(id: 7, brandId: 2, modelName: "Sentra", years: [2000, 2024]),
  CarModel(id: 8, brandId: 2, modelName: "Patrol", years: [1998, 2024]),
  CarModel(id: 9, brandId: 2, modelName: "Sunny", years: [1995, 2024]),

  // ---------------------------
  // HYUNDAI (BrandId = 3)
  // ---------------------------
  CarModel(id: 10, brandId: 3, modelName: "Elantra", years: [2001, 2024]),
  CarModel(id: 11, brandId: 3, modelName: "Sonata", years: [1999, 2024]),
  CarModel(id: 12, brandId: 3, modelName: "Tucson", years: [2003, 2024]),
  CarModel(id: 13, brandId: 3, modelName: "Santa Fe", years: [2001, 2024]),

  // ---------------------------
  // KIA (BrandId = 4)
  // ---------------------------
  CarModel(id: 14, brandId: 4, modelName: "Sportage", years: [2001, 2024]),
  CarModel(id: 15, brandId: 4, modelName: "Cerato", years: [2004, 2024]),
  CarModel(id: 16, brandId: 4, modelName: "Sorento", years: [2003, 2024]),
  CarModel(id: 17, brandId: 4, modelName: "Rio", years: [1999, 2024]),

  // ---------------------------
  // MERCEDES (BrandId = 5)
  // ---------------------------
  CarModel(id: 18, brandId: 5, modelName: "C-Class", years: [1995, 2024]),
  CarModel(id: 19, brandId: 5, modelName: "E-Class", years: [1995, 2024]),
  CarModel(id: 20, brandId: 5, modelName: "S-Class", years: [1991, 2024]),

  // ===========================
  // BMW (BrandId = 6)
  // ===========================
  CarModel(id: 23, brandId: 6, modelName: "3 Series", years: [1999, 2024]),
  CarModel(id: 24, brandId: 6, modelName: "5 Series", years: [1999, 2024]),
  CarModel(id: 25, brandId: 6, modelName: "7 Series", years: [1999, 2024]),
  CarModel(id: 26, brandId: 6, modelName: "X5", years: [2000, 2024]),

  // ===========================
  // AUDI (BrandId = 7)
  // ===========================
  CarModel(id: 28, brandId: 7, modelName: "A3", years: [2003, 2024]),
  CarModel(id: 29, brandId: 7, modelName: "A4", years: [2000, 2024]),
  CarModel(id: 30, brandId: 7, modelName: "A6", years: [2000, 2024]),
  CarModel(id: 31, brandId: 7, modelName: "Q5", years: [2009, 2024]),
  CarModel(id: 32, brandId: 7, modelName: "Q7", years: [2005, 2024]),

  // ===========================
  // VOLKSWAGEN (BrandId = 8)
  // ===========================
  CarModel(id: 33, brandId: 8, modelName: "Golf", years: [1998, 2024]),
  CarModel(id: 34, brandId: 8, modelName: "Passat", years: [1998, 2024]),
  CarModel(id: 35, brandId: 8, modelName: "Tiguan", years: [2008, 2024]),

  // ===========================
  // FORD (BrandId = 9)
  // ===========================
  CarModel(id: 36, brandId: 9, modelName: "Mustang", years: [1996, 2024]),
  CarModel(id: 37, brandId: 9, modelName: "Explorer", years: [1995, 2024]),
  CarModel(id: 38, brandId: 9, modelName: "F-150", years: [1990, 2024]),

  // ===========================
  // CHEVROLET (BrandId = 10)
  // ===========================
  CarModel(id: 39, brandId: 10, modelName: "Cruze", years: [2008, 2024]),
  CarModel(id: 40, brandId: 10, modelName: "Malibu", years: [1997, 2024]),
  CarModel(id: 41, brandId: 10, modelName: "Tahoe", years: [1998, 2024]),

  // ===========================
  // HONDA (BrandId = 11)
  // ===========================
  CarModel(id: 42, brandId: 11, modelName: "Civic", years: [1995, 2024]),
  CarModel(id: 43, brandId: 11, modelName: "Accord", years: [1995, 2024]),
  CarModel(id: 44, brandId: 11, modelName: "CR-V", years: [1997, 2024]),

  // ===========================
  // MAZDA (BrandId = 12)
  // ===========================
  CarModel(id: 45, brandId: 12, modelName: "Mazda 3", years: [2003, 2024]),
  CarModel(id: 46, brandId: 12, modelName: "Mazda 6", years: [2002, 2024]),
  CarModel(id: 47, brandId: 12, modelName: "CX-5", years: [2012, 2024]),

  // ===========================
  // MITSUBISHI (BrandId = 13)
  // ===========================
  CarModel(id: 48, brandId: 13, modelName: "Lancer", years: [2000, 2024]),
  CarModel(id: 49, brandId: 13, modelName: "Outlander", years: [2001, 2024]),
  CarModel(id: 50, brandId: 13, modelName: "Pajero", years: [1995, 2024]),

  // ===========================
  // JEEP (BrandId = 14)
  // ===========================
  CarModel(id: 51, brandId: 14, modelName: "Wrangler", years: [1995, 2024]),
  CarModel(
      id: 52, brandId: 14, modelName: "Grand Cherokee", years: [1995, 2024]),

  // ===========================
  // DODGE (BrandId = 15)
  // ===========================
  CarModel(id: 53, brandId: 15, modelName: "Charger", years: [2005, 2024]),
  CarModel(id: 54, brandId: 15, modelName: "Challenger", years: [2008, 2024]),

  // ===========================
  // PEUGEOT (BrandId = 16)
  // ===========================
  CarModel(id: 55, brandId: 16, modelName: "Peugeot 301", years: [2012, 2024]),
  CarModel(id: 56, brandId: 16, modelName: "Peugeot 5008", years: [2009, 2024]),
  CarModel(id: 57, brandId: 16, modelName: "Peugeot 3008", years: [2009, 2024]),

  // ===========================
  // RENAULT (BrandId = 17)
  // ===========================
  CarModel(id: 58, brandId: 17, modelName: "Logan", years: [2004, 2024]),
  CarModel(id: 59, brandId: 17, modelName: "Megane", years: [1996, 2024]),
  CarModel(id: 60, brandId: 17, modelName: "Duster", years: [2010, 2024]),

  // ===========================
  // VOLVO (BrandId = 18)
  // ===========================
  CarModel(id: 61, brandId: 18, modelName: "XC90", years: [2003, 2024]),
  CarModel(id: 62, brandId: 18, modelName: "XC60", years: [2008, 2024]),

  // ===========================
  // LAND ROVER (BrandId = 19)
  // ===========================
  CarModel(id: 63, brandId: 19, modelName: "Range Rover", years: [1995, 2024]),
  CarModel(id: 64, brandId: 19, modelName: "Discovery", years: [1998, 2024]),

  // ===========================
  // LEXUS (BrandId = 20)
  // ===========================
  CarModel(id: 65, brandId: 20, modelName: "ES", years: [2000, 2024]),
  CarModel(id: 66, brandId: 20, modelName: "RX", years: [1999, 2024]),
  CarModel(id: 67, brandId: 20, modelName: "LX", years: [1998, 2024]),

  // ===========================
  // SUZUKI (BrandId = 21)
  // ===========================
  CarModel(id: 68, brandId: 21, modelName: "Swift", years: [2000, 2024]),
  CarModel(id: 69, brandId: 21, modelName: "Vitara", years: [1999, 2024]),

  // ===========================
  // GMC (BrandId = 22)
  // ===========================
  CarModel(id: 70, brandId: 22, modelName: "Yukon", years: [1999, 2024]),
  CarModel(id: 71, brandId: 22, modelName: "Sierra", years: [1998, 2024]),

  // ===========================
  // INFINITI (BrandId = 23)
  // ===========================
  CarModel(id: 72, brandId: 23, modelName: "Q50", years: [2013, 2024]),
  CarModel(id: 73, brandId: 23, modelName: "QX60", years: [2014, 2024]),

  // ===========================
  // MG (BrandId = 24)
  // ===========================
  CarModel(id: 74, brandId: 24, modelName: "MG 5", years: [2012, 2024]),
  CarModel(id: 75, brandId: 24, modelName: "MG ZS", years: [2017, 2024]),

  // ===========================
  // OPEL (BrandId = 25)
  // ===========================
  CarModel(id: 76, brandId: 25, modelName: "Astra", years: [1998, 2024]),
  CarModel(id: 77, brandId: 25, modelName: "Insignia", years: [2009, 2024]),

  // ===========================
  // SKODA (BrandId = 26)
  // ===========================
  CarModel(id: 78, brandId: 26, modelName: "Octavia", years: [1998, 2024]),
  CarModel(id: 79, brandId: 26, modelName: "Superb", years: [2001, 2024]),

  // ===========================
  // SEAT (BrandId = 27)
  // ===========================
  CarModel(id: 80, brandId: 27, modelName: "Leon", years: [2000, 2024]),
  CarModel(id: 81, brandId: 27, modelName: "Ibiza", years: [1999, 2024]),

  // ===========================
  // SUBARU (BrandId = 28)
  // ===========================
  CarModel(id: 82, brandId: 28, modelName: "Impreza", years: [1998, 2024]),
  CarModel(id: 83, brandId: 28, modelName: "Forester", years: [2000, 2024]),

  // ===========================
  // GEELY (BrandId = 29)
  // ===========================
  CarModel(id: 84, brandId: 29, modelName: "Coolray", years: [2019, 2024]),
  CarModel(id: 85, brandId: 29, modelName: "Emgrand", years: [2015, 2024]),

  // ===========================
  // CHANGAN (BrandId = 30)
  // ===========================
  CarModel(id: 86, brandId: 30, modelName: "CS35", years: [2012, 2024]),
  CarModel(id: 87, brandId: 30, modelName: "CS75", years: [2014, 2024]),

  // ===========================
  // TESLA (BrandId = 31)
  // ===========================
  CarModel(id: 88, brandId: 31, modelName: "Model S", years: [2012, 2024]),
  CarModel(id: 89, brandId: 31, modelName: "Model 3", years: [2017, 2024]),
  CarModel(id: 90, brandId: 31, modelName: "Model X", years: [2015, 2024]),

  // ===========================
  // RAM (BrandId = 32)
  // ===========================
  CarModel(id: 91, brandId: 32, modelName: "RAM 1500", years: [2002, 2024]),
  CarModel(id: 92, brandId: 32, modelName: "RAM 2500", years: [2002, 2024]),

  // ===========================
  // JAGUAR (BrandId = 35)
  // ===========================
  CarModel(id: 93, brandId: 35, modelName: "XF", years: [2008, 2024]),
  CarModel(id: 94, brandId: 35, modelName: "F-Pace", years: [2016, 2024]),

  // ===========================
  // PORSCHE (BrandId = 34)
  // ===========================
  CarModel(id: 95, brandId: 34, modelName: "Cayenne", years: [2003, 2024]),
  CarModel(id: 96, brandId: 34, modelName: "Panamera", years: [2009, 2024]),

  // ===========================
  // BENTLEY (BrandId = 36)
  // ===========================
  CarModel(id: 97, brandId: 36, modelName: "Bentayga", years: [2016, 2024]),
  CarModel(id: 98, brandId: 36, modelName: "Continental", years: [2003, 2024]),

  // ===========================
  // ROLLS ROYCE (BrandId = 37)
  // ===========================
  CarModel(id: 99, brandId: 37, modelName: "Ghost", years: [2010, 2024]),
  CarModel(id: 100, brandId: 37, modelName: "Phantom", years: [2003, 2024]),

  // ===========================
  // LAMBORGHINI (BrandId = 40)
  // ===========================
  CarModel(id: 101, brandId: 40, modelName: "Huracan", years: [2014, 2024]),
  CarModel(id: 102, brandId: 40, modelName: "Aventador", years: [2011, 2024]),

  // ===========================
  // BUGATTI (BrandId = 39)
  // ===========================
  CarModel(id: 103, brandId: 39, modelName: "Chiron", years: [2016, 2024]),
];
