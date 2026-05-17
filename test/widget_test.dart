import 'package:flutter_test/flutter_test.dart';

import 'package:camarada_del_vacio/main.dart';

void main() {
  testWidgets('Pantalla de título carga el rótulo del juego',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AppCamaradaDelVacio());
    expect(find.text('CAMARADA'), findsOneWidget);
    expect(find.text('DEL VACÍO'), findsOneWidget);
  });
}
