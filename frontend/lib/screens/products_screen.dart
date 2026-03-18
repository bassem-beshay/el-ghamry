import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  String? _error;
  String? _nextUrl;

  int? _selectedCategoryId;
  String? _selectedStockStatus;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _nextUrl != null &&
        !_loading) {
      _loadMore();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _api.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getProducts(
        category: _selectedCategoryId,
        search: _searchController.text,
        stockStatus: _selectedStockStatus,
      );
      if (mounted) {
        setState(() {
          _products = data['results'] ?? [];
          _nextUrl = data['next'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_nextUrl == null) return;
    setState(() => _loading = true);
    try {
      final data = await _api.getProducts(nextUrl: _nextUrl);
      if (mounted) {
        setState(() {
          _products.addAll(data['results'] ?? []);
          _nextUrl = data['next'];
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: kWhite,
          title: const Text('تأكيد الحذف', style: TextStyle(color: kBlack)),
          content: const Text('هل أنت متأكد من حذف هذا المنتج؟',
              style: TextStyle(color: kBlack)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: kBlue)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: kWhite,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      try {
        await _api.deleteProduct(id);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المنتج'),
              backgroundColor: kBlue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: $e'),
              backgroundColor: kBlue,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: const Text('المنتجات'),
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            // ─── Search Bar ───
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: kBlack),
                decoration: InputDecoration(
                  hintText: 'بحث عن منتج...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: kBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: kBlue),
                          onPressed: () {
                            _searchController.clear();
                            _loadProducts();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBlue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBlue),
                  ),
                  filled: true,
                  fillColor: kWhite,
                ),
                onSubmitted: (_) => _loadProducts(),
              ),
            ),

            // ─── Filter Chips ───
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildFilterChip('الكل', null),
                  const SizedBox(width: 8),
                  _buildStockChip('متاح', 'available'),
                  const SizedBox(width: 8),
                  _buildStockChip('منخفض', 'low'),
                  const SizedBox(width: 8),
                  _buildStockChip('نفد', 'out'),
                  const SizedBox(width: 8),
                  ..._categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat['id'];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(cat['name']),
                        selected: isSelected,
                        selectedColor: kBlue,
                        backgroundColor: kWhite,
                        labelStyle: TextStyle(
                          color: isSelected ? kWhite : kBlack,
                        ),
                        side: const BorderSide(color: kBlue),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? cat['id'] : null;
                          });
                          _loadProducts();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Products List ───
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
            if (result == true) _loadProducts();
          },
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? categoryId) {
    final isSelected = _selectedCategoryId == categoryId && _selectedStockStatus == null;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: kBlue,
      backgroundColor: kWhite,
      labelStyle: TextStyle(color: isSelected ? kWhite : kBlack),
      side: const BorderSide(color: kBlue),
      onSelected: (selected) {
        setState(() {
          _selectedCategoryId = null;
          _selectedStockStatus = null;
        });
        _loadProducts();
      },
    );
  }

  Widget _buildStockChip(String label, String status) {
    final isSelected = _selectedStockStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: kBlue,
      backgroundColor: kWhite,
      labelStyle: TextStyle(color: isSelected ? kWhite : kBlack),
      side: const BorderSide(color: kBlue),
      onSelected: (selected) {
        setState(() {
          _selectedStockStatus = selected ? status : null;
          _selectedCategoryId = null;
        });
        _loadProducts();
      },
    );
  }

  Widget _buildBody() {
    if (_loading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: kBlue));
    }
    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: kBlue, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: kBlack)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: kWhite,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: kBlue, size: 48),
            SizedBox(height: 12),
            Text('لا توجد منتجات', style: TextStyle(color: kBlack, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kBlue,
      onRefresh: _loadProducts,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _products.length + (_nextUrl != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: kBlue),
              ),
            );
          }
          final product = _products[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final stock = product['stock'] ?? 0;
    String stockLabel;
    if (stock == 0) {
      stockLabel = 'نفد';
    } else if (stock <= 10) {
      stockLabel = 'منخفض ($stock)';
    } else {
      stockLabel = 'متاح ($stock)';
    }

    return Dismissible(
      key: Key('product_${product['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: kBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: kWhite, size: 28),
      ),
      confirmDismiss: (_) async {
        _deleteProduct(product['id']);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBlue.withAlpha(80)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            product['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kBlack,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                product['category_name'] ?? 'بدون قسم',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${product['price']} جنيه',
                    style: const TextStyle(
                      color: kBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBlue),
                    ),
                    child: Text(
                      stockLabel,
                      style: const TextStyle(color: kBlue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: kBlue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: product['id']),
                    ),
                  );
                  if (result == true) _loadProducts();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kBlue),
                onPressed: () => _deleteProduct(product['id']),
              ),
            ],
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product['id']),
              ),
            );
            if (result == true) _loadProducts();
          },
        ),
      ),
    );
  }
}
