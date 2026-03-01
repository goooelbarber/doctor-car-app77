class DtcInfo {
  final String titleAr;
  final String descAr;
  final String severity; // low/medium/high
  final List<String> actionsAr;

  const DtcInfo({
    required this.titleAr,
    required this.descAr,
    required this.severity,
    required this.actionsAr,
  });
}

class DtcDictionary {
  static const Map<String, DtcInfo> map = {
    "P0420": DtcInfo(
      titleAr: "كفاءة المحول الحفاز أقل من المطلوب",
      descAr: "قد يكون بسبب حساس أكسجين أو كاتاليست ضعيف.",
      severity: "medium",
      actionsAr: [
        "فحص حساس الأكسجين",
        "فحص تهريب عادم قبل الكاتاليست",
        "قياس كفاءة الكاتاليست",
      ],
    ),
    "P0301": DtcInfo(
      titleAr: "حريق ناقص في السلندر 1",
      descAr: "ممكن يسبب رعشة وضعف عزم ويؤثر على المحرك.",
      severity: "high",
      actionsAr: [
        "فحص بوجيهات/كويلات",
        "فحص بخاخات الوقود",
        "فحص ضغط السلندر",
      ],
    ),
  };

  static DtcInfo? get(String code) => map[code];
}
