import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/app.dart';

void main() {
  testWidgets('Placeholder экран рендерится после bootstrap', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TaskManagerApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Task Manager'), findsOneWidget);
  });
}
