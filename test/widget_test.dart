import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:learn_ar_3d/main.dart';
import 'package:learn_ar_3d/providers/app_state.dart';

void main() {
  testWidgets('App smoke test - splash screen renders title and navigates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AppState())],
        child: const LearnARApp(),
      ),
    );

    // Verify splash screen content
    expect(find.text('3D Learn AR'), findsOneWidget);

    // Tap splash screen to immediately navigate to Onboarding
    await tester.tap(find.text('3D Learn AR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify it smoothly navigates to Onboarding
    expect(find.text('Learn Anything\nin 3D'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
