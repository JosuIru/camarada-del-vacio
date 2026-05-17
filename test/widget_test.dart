import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camarada_del_vacio/main.dart';

void main() {
  testWidgets(
    'La pantalla de título arranca y muestra el botón "Iniciar procedimiento"',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AppCamaradaDelVacio());
      // El primer frame puede tener animaciones pendientes (estrella roja,
      // fondo de papel, etc.); damos una pasada extra para estabilizar.
      await tester.pump(const Duration(milliseconds: 100));

      // `BotonPropaganda` aplica `.toUpperCase()` internamente: el widget
      // de texto final es "INICIAR PROCEDIMIENTO", no "Iniciar procedimiento".
      expect(
        find.text('INICIAR PROCEDIMIENTO'),
        findsOneWidget,
        reason:
            'El botón principal del menú es el ancla canónica de la pantalla '
            'de título; si cambia su texto, hay que renombrar también este test.',
      );
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}
