import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/db.dart';

/// إعدادات التطبيق (اللغة، الوضع، الاسم). بتتحفظ على الجهاز.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState i = AppState._();

  bool _ready = false;
  String lang = 'ar';
  ThemeMode themeMode = ThemeMode.system;
  String userName = '';
  bool onboarded = false;

  /// المزامنة السحابية مقفولة افتراضيًا: التطبيق بيشتغل محليًا بالكامل.
  bool syncEnabled = false;

  bool get isAr => lang == 'ar';

  /// الإعدادات بتتحفظ في قاعدة البيانات المحلية نفسها (جدول meta).
  Future<void> load() async {
    final rows = await Db.i.raw.query('meta');
    final m = {for (final r in rows) '${r['key']}': r['value'] as String?};
    lang = m['pref_lang'] ?? 'ar';
    userName = m['pref_userName'] ?? '';
    onboarded = m['pref_onboarded'] == '1';
    syncEnabled = m['pref_syncEnabled'] == '1';
    switch (m['pref_theme']) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    _ready = true;
  }

  Future<void> _put(String k, String v) async {
    if (!_ready) return;
    await Db.i.raw.insert('meta', {'key': 'pref_$k', 'value': v}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> setLang(String v) async {
    lang = v;
    notifyListeners();
    await _put('lang', v);
  }

  Future<void> setTheme(ThemeMode m) async {
    themeMode = m;
    notifyListeners();
    await _put('theme', m == ThemeMode.light ? 'light' : m == ThemeMode.dark ? 'dark' : 'system');
  }

  Future<void> setUserName(String v) async {
    userName = v;
    notifyListeners();
    await _put('userName', v);
  }

  Future<void> completeOnboarding(String name) async {
    userName = name;
    onboarded = true;
    await _put('userName', name);
    await _put('onboarded', '1');
    notifyListeners();
  }

  Future<void> signOut() async {
    onboarded = false;
    await _put('onboarded', '0');
    notifyListeners();
  }

  Future<void> setSync(bool v) async {
    syncEnabled = v;
    notifyListeners();
    await _put('syncEnabled', v ? '1' : '0');
  }
}

/// اختصار للنص ثنائي اللغة: tr('عربي', 'English')
String tr(String ar, String en) => AppState.i.isAr ? ar : en;
