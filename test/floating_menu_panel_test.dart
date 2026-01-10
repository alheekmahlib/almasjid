import 'package:almasjid/core/widgets/floating_menu_panel/floating_menu_panel.dart';
import 'package:almasjid/core/widgets/floating_menu_panel/floating_menu_panel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('controller.physicalSide يتم تحديثه بعد البناء', (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: FloatingMenuPanel(
              controller: controller,
              panelWidth: 160,
              panelHeight: 80,
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(color: Colors.black),
              dockToStartInitially: true,
            ),
          ),
        ),
      ),
    );

    expect(controller.physicalSide.value, FloatingMenuPanelPhysicalSide.left);
  });

  testWidgets(
      'Vertical: controller.physicalSide = top عندما يكون المقبض بالأعلى',
      (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: FloatingMenuPanel(
              controller: controller,
              openMode: FloatingMenuPanelOpenMode.vertical,
              panelWidth: 200,
              panelHeight: 120,
              initialPosition: const Offset(140, 12),
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(color: Colors.black),
            ),
          ),
        ),
      ),
    );

    expect(controller.verticalSide.value, FloatingMenuPanelPhysicalSide.top);
  });

  testWidgets(
      'Vertical: controller.physicalSide = bottom عندما يكون المقبض بالأسفل',
      (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: FloatingMenuPanel(
              controller: controller,
              openMode: FloatingMenuPanelOpenMode.vertical,
              panelWidth: 200,
              panelHeight: 120,
              initialPosition: const Offset(140, 520),
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(color: Colors.black),
            ),
          ),
        ),
      ),
    );

    expect(controller.verticalSide.value, FloatingMenuPanelPhysicalSide.bottom);
  });

  testWidgets('يفتح ويغلق ويطبّق العرض/الارتفاع', (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingMenuPanel(
                controller: controller,
                panelWidth: 200,
                panelHeight: 120,
                handleChild: const Icon(Icons.menu),
                panelChild: const ColoredBox(
                  color: Colors.red,
                  child: Center(child: Text('PANEL')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('PANEL'), findsNothing);

    await tester.tap(find.byKey(const Key('floating_menu_panel_handle')));
    await tester.pumpAndSettle();

    expect(find.text('PANEL'), findsOneWidget);

    final panelSize =
        tester.getSize(find.byKey(const Key('floating_menu_panel_panel')));
    expect(panelSize.width, 200);
    expect(panelSize.height, 120);

    await tester.tap(find.byKey(const Key('floating_menu_panel_handle')));
    await tester.pumpAndSettle();

    expect(find.text('PANEL'), findsNothing);
  });

  testWidgets('RTL: اللوحة تظهر يسار المقبض عند الدوك start', (tester) async {
    final controller = FloatingMenuPanelController(initialIsOpen: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Stack(
              children: [
                FloatingMenuPanel(
                  controller: controller,
                  panelWidth: 160,
                  panelHeight: 80,
                  handleChild: const Icon(Icons.menu),
                  panelChild: const ColoredBox(color: Colors.blue),
                  dockToStartInitially: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final handleRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_handle')));
    final panelRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_panel')));

    expect(panelRect.left, lessThan(handleRect.left));
  });

  testWidgets('LTR: اللوحة تظهر يمين المقبض عند الدوك start', (tester) async {
    final controller = FloatingMenuPanelController(initialIsOpen: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                FloatingMenuPanel(
                  controller: controller,
                  panelWidth: 160,
                  panelHeight: 80,
                  handleChild: const Icon(Icons.menu),
                  panelChild: const ColoredBox(color: Colors.green),
                  dockToStartInitially: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final handleRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_handle')));
    final panelRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_panel')));

    expect(panelRect.left, greaterThan(handleRect.left));
  });

  testWidgets('Vertical: إذا كان المقبض بالأعلى تفتح للأسفل', (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: FloatingMenuPanel(
              controller: controller,
              openMode: FloatingMenuPanelOpenMode.vertical,
              panelWidth: 200,
              panelHeight: 120,
              initialPosition: const Offset(12, 40),
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(
                color: Colors.orange,
                child: Center(child: Text('VPANEL')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('floating_menu_panel_handle')));
    await tester.pumpAndSettle();

    final handleRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_handle')));
    final panelRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_panel')));

    expect(panelRect.top, greaterThanOrEqualTo(handleRect.bottom));
  });

  testWidgets('Panel لا يتجاوز عرض الشاشة عند panelWidth كبير', (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: FloatingMenuPanel(
              controller: controller,
              openMode: FloatingMenuPanelOpenMode.vertical,
              panelWidth: 1000,
              panelHeight: 120,
              initialPosition: const Offset(12, 40),
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(color: Colors.orange),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('floating_menu_panel_handle')));
    await tester.pumpAndSettle();

    final panelSize =
        tester.getSize(find.byKey(const Key('floating_menu_panel_panel')));

    // 320 - (12 + 12) = 296
    expect(panelSize.width, lessThanOrEqualTo(296));
  });

  testWidgets('Vertical: عند امتلاء العرض، السحب يمينًا يثبت المقبض يمينًا',
      (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: FloatingMenuPanel(
              controller: controller,
              openMode: FloatingMenuPanelOpenMode.vertical,
              panelWidth: 1000,
              panelHeight: 120,
              initialPosition: const Offset(12, 40),
              handleWidth: 130,
              handleHeight: 52,
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(color: Colors.orange),
            ),
          ),
        ),
      ),
    );

    // اسحب يمينًا ثم اترك ليتم snap.
    await tester.drag(
      find.byKey(const Key('floating_menu_panel_handle')),
      const Offset(220, 0),
    );
    await tester.pumpAndSettle();

    final handleRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_handle')));

    // داخل عرض 320 مع padding 12 + 12، المقبض عند اليمين يكون تقريبًا بعد منتصف الشاشة.
    expect(handleRect.left, greaterThan(140));
  });

  testWidgets('Vertical: إذا كان المقبض بالأسفل تفتح للأعلى', (tester) async {
    final controller = FloatingMenuPanelController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: FloatingMenuPanel(
              controller: controller,
              openMode: FloatingMenuPanelOpenMode.vertical,
              panelWidth: 200,
              panelHeight: 120,
              initialPosition: const Offset(12, 520),
              handleChild: const Icon(Icons.menu),
              panelChild: const ColoredBox(
                color: Colors.purple,
                child: Center(child: Text('UPANEL')),
              ),
            ),
          ),
        ),
      ),
    );

    final closedHandleRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_handle')));

    await tester.tap(find.byKey(const Key('floating_menu_panel_handle')));
    await tester.pumpAndSettle();

    final handleRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_handle')));
    final panelRect =
        tester.getRect(find.byKey(const Key('floating_menu_panel_panel')));

    // المقبض لا يتحرك.
    expect(handleRect.top, closedHandleRect.top);

    // اللوحة فوق المقبض.
    expect(panelRect.bottom, lessThanOrEqualTo(handleRect.top));
  });
}
