import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dawaei/main.dart';
import 'package:dawaei/src/services/api_service.dart';

void main() {
  test('android emulator base URLs are prioritized before the LAN fallback', () {
    final service = ApiService.create(
      baseUrl:
          'http://192.168.0.164:8000/api,http://10.0.2.2:8000/api,http://127.0.0.1:8000/api',
    );

    expect(service.dio.options.baseUrl, 'http://192.168.0.164:8000/api');
  });

  testWidgets('app loads the splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Smart Pharmacy'), findsNothing);
  });
}
