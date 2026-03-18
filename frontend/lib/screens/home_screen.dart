import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';
import 'products_screen.dart';
import 'prescriptions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getProductsSummary();
      if (mounted) setState(() => _summary = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: const Text('صيدلية الغمري'),
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          color: kBlue,
          onRefresh: _loadSummary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Summary Section ───
              const Text(
                'ملخص المخزون',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kBlack,
                ),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: kBlue))
              else if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Text(_error!, style: const TextStyle(color: kBlack)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadSummary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          foregroundColor: kWhite,
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              else
                _buildSummaryGrid(),

              const SizedBox(height: 32),

              // ─── Navigation Section ───
              const Text(
                'الأقسام الرئيسية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kBlack,
                ),
              ),
              const SizedBox(height: 12),
              _buildNavCard(
                icon: Icons.medication,
                title: 'المنتجات',
                subtitle: 'إدارة الأدوية والمنتجات',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()),
                  ).then((_) => _loadSummary());
                },
              ),
              const SizedBox(height: 12),
              _buildNavCard(
                icon: Icons.description,
                title: 'الروشتات',
                subtitle: 'إدارة الروشتات الطبية',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNavCard(
                icon: Icons.category,
                title: 'الأقسام',
                subtitle: 'إدارة أقسام المنتجات',
                onTap: () {
                  // Navigate to categories screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          icon: Icons.inventory_2,
          title: 'إجمالي المنتجات',
          value: '${_summary?['total_products'] ?? 0}',
        ),
        _buildSummaryCard(
          icon: Icons.check_circle_outline,
          title: 'متاح',
          value: '${_summary?['available'] ?? 0}',
        ),
        _buildSummaryCard(
          icon: Icons.warning_amber,
          title: 'مخزون منخفض',
          value: '${_summary?['low_stock'] ?? 0}',
        ),
        _buildSummaryCard(
          icon: Icons.remove_shopping_cart,
          title: 'نفد من المخزون',
          value: '${_summary?['out_of_stock'] ?? 0}',
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBlue, width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kBlue, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBlue, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kWhite, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: kBlue, size: 20),
          ],
        ),
      ),
    );
  }
}
