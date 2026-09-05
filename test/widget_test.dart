// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tarjeta_pare/main.dart';

void main() {
  testWidgets('muestra el acceso SGI', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Acceso Personal SGI'), findsOneWidget);
    expect(find.text('Ingresar SGI Móvil'), findsOneWidget);
    expect(find.text('RUT USUARIO'), findsOneWidget);
  });

  testWidgets('formatea el RUT con puntos y guion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final campoRut = find.byType(TextFormField).first;
    await tester.enterText(campoRut, '201552451');

    final textField = tester.widget<TextFormField>(campoRut);
    expect(textField.controller?.text, '20.155.245-1');
  });
}
