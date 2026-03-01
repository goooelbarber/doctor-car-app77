import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:doctor_car_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // تحميل env قبل تشغيل التطبيق
    await dotenv.load(fileName: ".env");
  });

  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // ننتظر أي async build
    await tester.pumpAndSettle();

    // نتأكد إن فيه Scaffold واحد على الأقل
    expect(find.byType(Scaffold), findsWidgets);

    // نتأكد إن MaterialApp موجود
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
