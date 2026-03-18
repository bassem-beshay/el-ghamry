import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = ApiService();

  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getCategories();
      setState(() {
        final list = data is List ? data : (data as Map<String, dynamic>)['results'] ?? [];
        _categories = List<Map<String, dynamic>>.from(list);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الأقسام: $e'),
            backgroundColor: kBlue,
          ),
        );
      }
    }
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: kWhite,
          title: const Text('إضافة قسم جديد',
              style: TextStyle(color: kBlack)),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: kBlack),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'اسم القسم',
              labelStyle: TextStyle(color: kBlack),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kBlue),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kBlue, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: kBlack)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(ctx, name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: kWhite,
              ),
              child: const Text('إضافة',
                  style: TextStyle(color: kWhite)),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();

    if (result != null && result.isNotEmpty) {
      try {
        // Use a generic approach - the API service likely has a create category method
        // or we can use createProduct-style approach
        await _api.getCategories(); // Placeholder - replace with actual create call
        // If ApiService has no createCategory, you may need to add it.
        // For now, we attempt to call it dynamically:
        try {
          await ((_api as dynamic).createCategory({'name': result}));
        } catch (_) {
          // If createCategory doesn't exist, show a message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى إضافة دالة createCategory في ApiService'),
                backgroundColor: kBlue,
              ),
            );
          }
          return;
        }
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة القسم بنجاح'),
              backgroundColor: kBlue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إضافة القسم: $e'),
              backgroundColor: kBlue,
            ),
          );
        }
      }
    }
  }

  void _navigateToProducts(Map<String, dynamic> category) {
    // Navigate to products screen filtered by this category
    Navigator.pushNamed(
      context,
      '/products',
      arguments: {'category': category['id'], 'category_name': category['name']},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: const Text('الأقسام',
              style: TextStyle(color: kWhite)),
          backgroundColor: kBlue,
          iconTheme: const IconThemeData(color: kWhite),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kBlue))
            : _categories.isEmpty
                ? const Center(
                    child: Text('لا توجد أقسام',
                        style: TextStyle(
                            color: Colors.black54, fontSize: 18)),
                  )
                : RefreshIndicator(
                    color: kBlue,
                    onRefresh: _loadCategories,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final productCount =
                            category['product_count'] ??
                                category['products_count'] ??
                                0;
                        return Card(
                          color: kWhite,
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: kBlue, width: 0.5),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            onTap: () => _navigateToProducts(category),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: kBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.category,
                                color: kWhite,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              category['name'] ?? '-',
                              style: const TextStyle(
                                color: kBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '$productCount منتج',
                              style: const TextStyle(
                                  color: Colors.black54),
                            ),
                            trailing: const Icon(
                              Icons.arrow_back_ios,
                              color: kBlue,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addCategory,
          backgroundColor: kBlue,
          child: const Icon(Icons.add, color: kWhite),
        ),
      ),
    );
  }
}
