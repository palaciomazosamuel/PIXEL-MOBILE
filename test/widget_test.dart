import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_mobile/app/pixel_mobile_app.dart';

void main() {
  testWidgets('muestra el login de PIXEL Mobile', (WidgetTester tester) async {
    await tester.pumpWidget(const PixelMobileApp());

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
