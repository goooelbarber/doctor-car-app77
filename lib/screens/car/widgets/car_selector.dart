// 📁 lib/screens/car/widgets/car_selector.dart

import 'package:doctor_car_app/models/car_brand.dart';
import 'package:doctor_car_app/models/car_model_name.dart';
import 'package:doctor_car_app/services/car_types_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarSelector extends StatefulWidget {
  final bool darkMode;
  final Function(String brand, String model, int year) onSelect;

  const CarSelector({
    super.key,
    required this.darkMode,
    required this.onSelect,
  });

  @override
  State<CarSelector> createState() => _CarSelectorState();
}

class _CarSelectorState extends State<CarSelector> {
  CarBrand? selectedBrand;
  CarModelName? selectedModel;
  int? selectedYear;

  List<CarBrand> brands = [];
  List<CarModelName> models = [];
  List<int> years = [];

  bool loadingBrands = true;
  bool loadingModels = false;
  bool loadingYears = false;

  @override
  void initState() {
    super.initState();
    loadBrands();
  }

  // 🟦 Load Brands
  Future<void> loadBrands() async {
    setState(() => loadingBrands = true);
    brands = await CarTypesService.getBrands();
    setState(() => loadingBrands = false);
  }

  // 🟦 Load Models
  Future<void> loadModels(String brandId) async {
    setState(() => loadingModels = true);
    models = await CarTypesService.getModels(brandId);
    setState(() => loadingModels = false);
  }

  // 🟦 Load Years
  Future<void> loadYears(String brand, String model) async {
    setState(() => loadingYears = true);
    years = await CarTypesService.getYears(brand, model);
    setState(() => loadingYears = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        widget.darkMode ? Colors.white : const Color(0xFF0A1F44);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BRAND
        Text("Brand",
            style: GoogleFonts.cairo(
                color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),

        loadingBrands
            ? const CircularProgressIndicator(color: Colors.amber)
            : DropdownButtonFormField<CarBrand>(
                decoration: _decor(),
                value: selectedBrand,
                items: brands
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b.name,
                              style: GoogleFonts.cairo(color: textColor)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                    selectedModel = null;
                    selectedYear = null;
                    models.clear();
                    years.clear();
                  });

                  loadModels(value!.id);
                },
              ),

        const SizedBox(height: 20),

        // MODEL
        Text("Model",
            style: GoogleFonts.cairo(
                color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),

        loadingModels
            ? const CircularProgressIndicator(color: Colors.amber)
            : DropdownButtonFormField<CarModelName>(
                decoration: _decor(),
                value: selectedModel,
                items: models
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.model,
                              style: GoogleFonts.cairo(color: textColor)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedModel = value;
                    selectedYear = null;
                    years.clear();
                  });

                  loadYears(selectedBrand!.id, value!.model);
                },
              ),

        const SizedBox(height: 20),

        // YEAR
        Text("Production Year",
            style: GoogleFonts.cairo(
                color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),

        loadingYears
            ? const CircularProgressIndicator(color: Colors.amber)
            : DropdownButtonFormField<int>(
                decoration: _decor(),
                value: selectedYear,
                items: years
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text("$y",
                              style: GoogleFonts.cairo(color: textColor)),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedYear = value;
                  widget.onSelect(
                      selectedBrand!.name, selectedModel!.model, value!);
                },
              ),
      ],
    );
  }

  InputDecoration _decor() {
    return InputDecoration(
      filled: true,
      fillColor: widget.darkMode ? Colors.white12 : Colors.black12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
