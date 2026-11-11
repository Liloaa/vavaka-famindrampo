import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vavaka_famindrapo/main.dart';
import 'package:vavaka_famindrapo/providers/theme_provider.dart';

void main() {
  testWidgets('le mode nuit se bascule et reste enregistré',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();
    await themeProvider.charger();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const VavakaApp(),
      ),
    );
    await tester.pump();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byTooltip('Activer le mode nuit'));
    await tester.pump();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    expect(find.byTooltip('Activer le mode jour'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool('mode_nuit'),
      isTrue,
    );
  });
}
