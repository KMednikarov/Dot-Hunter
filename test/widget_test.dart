// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dot_hunter/main.dart';
import 'package:dot_hunter/bloc/game_cubit.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('Game starts with score 0 and 5 lives', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    expect(find.text('Score: 0'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(5));
  });

  testWidgets('Losing a life greys out one heart', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Score: 0'));
    final cubit = BlocProvider.of<GameCubit>(context);

    final nonRedDot =
        cubit.state.dots.firstWhere((dot) => dot.color != Colors.red);
    cubit.handleTap(nonRedDot.position);
    await tester.pump();

    final hearts =
        tester.widgetList<Icon>(find.byIcon(Icons.favorite)).toList();
    final redHearts =
        hearts.where((icon) => icon.color == Colors.red).length;
    final greyHearts =
        hearts.where((icon) => icon.color == Colors.grey).length;

    expect(redHearts, 4);
    expect(greyHearts, 1);
  });

  testWidgets('Tapping empty space loses a life', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Score: 0'));
    final cubit = BlocProvider.of<GameCubit>(context);

    cubit.handleTap(const Offset(-100, -100));
    await tester.pump();

    final hearts =
        tester.widgetList<Icon>(find.byIcon(Icons.favorite)).toList();
    final redHearts =
        hearts.where((icon) => icon.color == Colors.red).length;
    final greyHearts =
        hearts.where((icon) => icon.color == Colors.grey).length;

    expect(redHearts, 4);
    expect(greyHearts, 1);
  });

  testWidgets('Using slow powerup does not lose a life',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    final initialHearts = tester
        .widgetList<Icon>(find.byIcon(Icons.favorite))
        .where((icon) => icon.color == Colors.red)
        .length;

    await tester.tap(find.byIcon(Icons.flash_on));
    await tester.pump();

    final heartsAfter = tester
        .widgetList<Icon>(find.byIcon(Icons.favorite))
        .where((icon) => icon.color == Colors.red)
        .length;

    expect(heartsAfter, initialHearts);
  });
}
