import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dawaei/main.dart';
import 'package:dawaei/src/services/api_service.dart';

void main() {
  test('production API base URL is used', () {
    final service = ApiService.create(
      baseUrl: 'https://smart-pharmacy-backend-1.onrender.com/api',
    );

    expect(
      service.dio.options.baseUrl,
      'https://smart-pharmacy-backend-1.onrender.com/api',
    );
  });

  testWidgets('app loads the application shell initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
