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

import 'package:dot_hunter/main.dart';
import 'package:dot_hunter/bloc/game_cubit.dart';

void main() {
  testWidgets('Game starts with score 0 and 5 lives', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Score: 0'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(5));
  });

  testWidgets('Losing a life greys out one heart', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Access the GameCubit through the context of the Scaffold.
    final context = tester.element(find.byType(Scaffold));
    final cubit = BlocProvider.of<GameCubit>(context);

    // Tap on a non-red dot to lose a life.
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

    final context = tester.element(find.byType(Scaffold));
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
}
