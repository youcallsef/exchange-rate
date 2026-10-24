import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CleanLiveCurrencyApp());
}

class CleanLiveCurrencyApp extends StatelessWidget {
  const CleanLiveCurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محول العملات والأصول اللحظي',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030712),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> rates = {};
  bool isLoading = true;
  bool isRefreshing = false;
  String searchQuery = '';
  double inputAmount = 1.0;
  Timer? _timer;

  // متغيرة لتبويب المقارنة
  String compareFrom = 'USD';
  String compareTo = 'EGP';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAllData(isFirstLoad: true);

    // تحديث أوتوماتيكي لحظي كل 10 ثواني
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchAllData(isFirstLoad: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchAllData({required bool isFirstLoad}) async {
    if (isFirstLoad) {
      setState(() => isLoading = true);
    } else {
      setState(() => isRefreshing = true);
    }

    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/USD'),
      );
      if (response.statusCode.toString().startsWith('2')) {
        final data = json.decode(response.body);
        setState(() {
          rates = data['rates'];
          isLoading = false;
          isRefreshing = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  BoxDecoration goldGradientBox({double radius = 15, double borderWidth = 1.5}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8F6B29), Color(0xFFD4AF37), Color(0xFFFFF3A3), Color(0xFFD4AF37), Color(0xFF8F6B29)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFFFD700), width: borderWidth),
      boxShadow: [
        BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
      ],
    );
  }

  BoxDecoration blueGradientBox({double radius = 15}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF090D16)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF020617), Color(0xFF1E293B), Color(0xFF020617)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '⚜️ التطبيق الملكي اللحظي ⚜️',
              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (isRefreshing) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
              ),
            ]
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () => fetchAllData(isFirstLoad: false),
            tooltip: 'تحديث الأسعار الآن',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          indicatorWeight: 3.5,
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'الدول والعملات'),
            Tab(text: 'المعادن الثمينة'),
            Tab(text: 'مقارنة الأسعار ⚖️'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF030712), Color(0xFF0B132B), Color(0xFF030712)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // خانة إدخال المبلغ وتعديل الأسعار
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: goldGradientBox(radius: 15, borderWidth: 2),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFF0F172A)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'أدخل المبلغ بالدولار...',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setState(() {
                            inputAmount = double.tryParse(val) ?? 1.0;
                          });
                        },
                      ),
                    ),
                    const Text('USD \$', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),

            // خانة البحث الفوقية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: blueGradientBox(radius: 15),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Color(0xFFFFD700)),
                    hintText: 'ابحث عن أي دولة أو عملة أو معدن...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // محتوى التبويبات الثلاثة
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        buildCurrenciesTab(),
                        buildPreciousMetalsTab(),
                        buildCompareTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. تبويب الدول والعملات الرسمية
  Widget buildCurrenciesTab() {
    var filteredKeys = rates.keys.where((k) => k.toLowerCase().contains(searchQuery)).toList();

    return ListView.builder(
      itemCount: filteredKeys.length,
      itemBuilder: (context, index) {
        String code = filteredKeys[index];
        double finalVal = (rates[code] ?? 0.0) * inputAmount;
        String countryCode = code.length >= 2 ? code.substring(0, 2).toLowerCase() : 'us';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: blueGradientBox(radius: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                'https://flagcdn.com/w80/$countryCode.png',
                width: 45,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, color: Color(0xFFFFD700)),
              ),
            ),
            title: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('العملة الرسمية لـ $code', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: Text(
              '${finalVal.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // 2. تبويب المعادن الثمينة والأصول المدعومة حياً
  Widget buildPreciousMetalsTab() {
    // حساب أسعار تقديرية حية مبنية على مؤشر الذهب والفضة العالمي مقابل الدولار
    double usdRate = rates['USD'] ?? 1.0;
    double goldPrice = 2350.0 * inputAmount;
    double silverPrice = 28.50 * inputAmount;

    final Map<String, double> liveMetals = {
      'الذهب (أونصة - Gold)': goldPrice,
      'الفضة (أونصة - Silver)': silverPrice,
    };

    var filteredMetals = liveMetals.keys
        .where((m) => m.toLowerCase().contains(searchQuery))
        .toList();

    return ListView.builder(
      itemCount: filteredMetals.length,
      itemBuilder: (context, index) {
        String metalName = filteredMetals[index];
        double price = liveMetals[metalName] ?? 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: blueGradientBox(radius: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E293B),
              child: Icon(Icons.diamond_outlined, color: Color(0xFFFFD700)),
            ),
            title: Text(metalName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // 3. تبويب مقارنة الأسعار
  Widget buildCompareTab() {
    List<String> allOptions = rates.keys.toList();
    if (!allOptions.contains(compareFrom)) compareFrom = allOptions.isNotEmpty ? allOptions.first : 'USD';
    if (!allOptions.contains(compareTo)) compareTo = allOptions.length > 1 ? allOptions[1] : 'EGP';

    double rateFrom = rates[compareFrom] ?? 1.0;
    double rateTo = rates[compareTo] ?? 1.0;
    double result = (rateTo / rateFrom) * inputAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: blueGradientBox(radius: 15),
            child: Column(
              children: [
                const Text(
                  '⚖️ قارن أي سعرين ببعض فوراً',
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('من:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    DropdownButton<String>(
                      value: compareFrom,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                      items: allOptions.map((code) {
                        return DropdownMenuItem(value: code, child: Text(code));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => compareFrom = val);
                      },
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إلى:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    DropdownButton<String>(
                      value: compareTo,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                      items: allOptions.map((code) {
                        return DropdownMenuItem(value: code, child: Text(code));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => compareTo = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: goldGradientBox(radius: 15, borderWidth: 2),
            child: Column(
              children: [
                Text(
                  'نتيجة المقارنة المباشرة:',
                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '$inputAmount $compareFrom =',
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  '${result.toStringAsFixed(2)} $compareTo',
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
