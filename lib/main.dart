import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EngXApp());
}

// --- الألوان والتصميم ---
class AppTheme {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceAlt = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);
  static const Color primary = Color(0xFF1F6FEB);
  static const Color primaryLight = Color(0xFF58A6FF);
  static const Color success = Color(0xFF2EA043);
  static const Color danger = Color(0xFFCF222E);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF8B949E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primaryLight,
          surface: surface,
          error: danger,
          onPrimary: Colors.white,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primaryLight,
          unselectedItemColor: textMuted,
        ),
      );
}

class EngXApp extends StatelessWidget {
  const EngXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EngX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersScreen(),
    const AssetsScreen(),
    const ClientsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'أوامر الشغل'),
          BottomNavigationBarItem(icon: Icon(Icons.precision_manufacturing_rounded), label: 'الأجهزة'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'العملاء'),
        ],
      ),
    );
  }
}

// ==========================================
// 1. شاشة الرئيسية (مؤقتة)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('شاشة الرئيسية (لوحة التحكم)', style: TextStyle(fontSize: 18, color: AppTheme.textPrimary))),
    );
  }
}

// ==========================================
// 2. شاشة أوامر الشغل (مؤقتة)
// ==========================================
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('شاشة أوامر الشغل', style: TextStyle(fontSize: 18, color: AppTheme.textPrimary))),
    );
  }
}

// ==========================================
// 3. شاشة الأجهزة (كاملة)
// ==========================================
class Asset {
  final String id;
  final String name;
  final String serialNumber;

  Asset({required this.id, required this.name, required this.serialNumber});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'serialNumber': serialNumber};

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        id: json['id'],
        name: json['name'],
        serialNumber: json['serialNumber'],
      );
}

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  List<Asset> assets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('engx_assets');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        assets = decoded.map((json) => Asset.fromJson(json)).toList();
      });
    }
    setState(() { isLoading = false; });
  }

  Future<void> _saveAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(assets.map((a) => a.toJson()).toList());
    await prefs.setString('engx_assets', encoded);
  }

  void _addAsset(String name, String sn) {
    if (name.isEmpty) return;
    setState(() {
      assets.add(Asset(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, serialNumber: sn));
    });
    _saveAssets();
  }

  void _deleteAsset(int index) {
    setState(() { assets.removeAt(index); });
    _saveAssets();
  }

  void _showAddAssetDialog() {
    final nameController = TextEditingController();
    final snController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة جهاز جديد', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'اسم الجهاز', prefixIcon: Icon(Icons.precision_manufacturing)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: snController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'الرقم التسلسلي', prefixIcon: Icon(Icons.numbers)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () {
              _addAsset(nameController.text, snController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryLight));

    return Scaffold(
      appBar: AppBar(title: const Text('الأجهزة والمعدات')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssetDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: assets.isEmpty
          ? const Center(child: Text('لا يوجد أجهزة مسجلة.\nاضغط + لإضافة جهاز.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return Card(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.surfaceAlt, child: Icon(Icons.settings_suggest, color: AppTheme.primaryLight)),
                    title: Text(asset.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text(asset.serialNumber.isEmpty ? 'لا يوجد رقم' : 'S/N: ${asset.serialNumber}', style: const TextStyle(color: AppTheme.textMuted)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.danger), onPressed: () => _deleteAsset(index)),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// 4. شاشة العملاء (كاملة)
// ==========================================
class Client {
  final String id;
  final String name;
  final String phone;

  Client({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};

  factory Client.fromJson(Map<String, dynamic> json) => Client(id: json['id'], name: json['name'], phone: json['phone']);
}

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('engx_clients');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        clients = decoded.map((json) => Client.fromJson(json)).toList();
      });
    }
    setState(() { isLoading = false; });
  }

  Future<void> _saveClients() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(clients.map((c) => c.toJson()).toList());
    await prefs.setString('engx_clients', encoded);
  }

  void _addClient(String name, String phone) {
    if (name.isEmpty) return;
    setState(() {
      clients.add(Client(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, phone: phone));
    });
    _saveClients();
  }

  void _deleteClient(int index) {
    setState(() { clients.removeAt(index); });
    _saveClients();
  }

  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة عميل جديد', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'اسم العميل', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () {
              _addClient(nameController.text, phoneController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryLight));

    return Scaffold(
      appBar: AppBar(title: const Text('العملاء')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('لا يوجد عملاء بعد.\nاضغط + لإضافة عميل.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.surfaceAlt, child: Icon(Icons.person, color: AppTheme.primaryLight)),
                    title: Text(client.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text(client.phone.isEmpty ? 'لا يوجد رقم' : client.phone, style: const TextStyle(color: AppTheme.textMuted)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.danger), onPressed: () => _deleteClient(index)),
                  ),
                );
              },
            ),
    );
  }
}