class ApiConfig {
  static const String baseUrl = "http://192.168.1.10:5000";

  // 🔥 Google Maps API Key (بدون أي إضافات)
  static const String googleMapsApiKey =
      "AIzaSyD9BGSScE-DU9nbdFgIbJV4fbNspNdPg_M";

  // 🌍 Google Autocomplete API
  static String autocomplete(String text) =>
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=$googleMapsApiKey&language=ar&components=country:eg";

  // 📌 Google Place Details
  static String placeDetails(String placeId) =>
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapsApiKey&language=ar";

  // 🌐 Server APIs
  static String get orders => "$baseUrl/api/orders";
  static String get technicians => "$baseUrl/api/technicians";
  static String get feedback => "$baseUrl/api/feedback";
  static String get payments => "$baseUrl/api/payments";

  // ❌ socket placeholder (يجب تطويره)
  static get socket => null;

  // ❌ snapToRoad placeholder (يجب تطويره)
  static snapToRoad(double latitude, double longitude) {
    // TODO: Implement or remove
  }
}
