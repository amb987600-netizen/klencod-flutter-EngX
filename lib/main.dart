import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_state.dart';
import 'core/theme.dart';
import 'data/db.dart';
import 'screens/onboarding.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // أي خطأ بيظهر على الشاشة بدل ما التطبيق يفضل واقف على أيقونة البداية.
  runZonedGuarded(() => runApp(const BootApp()), (e, st) => debugPrint('Uncaught: $e\n$st'));
}

/// بيجهز الإعدادات وقاعدة البيانات، وبيعرض أي مشكلة بوضوح.
class BootApp extends StatefulWidget {
  const BootApp({super.key});
  @override
  State<BootApp> createState() => _BootAppState();
}

class _BootAppState extends State<BootApp> {
  late Future<void> _init = _start();

  Future<void> _start() async {
    await AppState.i.load().timeout(const Duration(seconds: 15));
    await Db.i.open().timeout(const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done && !snap.hasError) return const EngXApp();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: snap.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        const Text('تعذّر تشغيل التطبيق / App failed to start'),
                        const SizedBox(height: 12),
                        SelectableText('${snap.error}', textDirection: TextDirection.ltr),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: () => setState(() => _init = _start()), child: const Text('Retry')),
                      ]),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class EngXApp extends StatelessWidget {
  const EngXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.i,
      builder: (context, _) {
        final st = AppState.i;
        return MaterialApp(
          title: 'EngX',
          debugShowCheckedModeBanner: false,
          locale: Locale(st.lang),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: st.themeMode,
          home: st.onboarded ? const Shell() : const OnboardingScreen(),
        );
      },
    );
  }
}