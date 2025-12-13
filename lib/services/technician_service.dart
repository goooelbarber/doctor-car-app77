class TechnicianService {
  Future<String> findAvailableTechnician(List technicians) async {
    for (var tech in technicians) {
      if (tech["available"] == true) {
        return tech["name"];
      }
    }
    return "لا يوجد فني متاح الآن";
  }
}
