import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _product;
  List<dynamic> _stockLogs = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  bool _editing = false;
  String? _error;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _barcodeController;
  late TextEditingController _manufacturerController;
  int? _selectedCategoryId;
  bool _requiresPrescription = false;

  // Stock update
  final TextEditingController _stockQtyController = TextEditingController(text: '1');
  final TextEditingController _stockNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    _barcodeController = TextEditingController();
    _manufacturerController = TextEditingController();
    _loadAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _barcodeController.dispose();
    _manufacturerController.dispose();
    _stockQtyController.dispose();
    _stockNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getProduct(widget.productId),
        _api.getProductStockLogs(widget.productId),
        _api.getCategories(),
      ]);
      if (mounted) {
        final product = results[0] as Map<String, dynamic>;
        setState(() {
          _product = product;
          _stockLogs = results[1] as List<dynamic>;
          _categories = results[2] as List<dynamic>;
          _populateForm(product);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _populateForm(Map<String, dynamic> product) {
    _nameController.text = product['name'] ?? '';
    _priceController.text = product['price']?.toString() ?? '';
    _descController.text = product['description'] ?? '';
    _barcodeController.text = product['barcode'] ?? '';
    _manufacturerController.text = product['manufacturer'] ?? '';
    _selectedCategoryId = product['category'];
    _requiresPrescription = product['requires_prescription'] ?? false;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final data = {
        'name': _nameController.text,
        'price': _priceController.text,
        'description': _descController.text,
        'barcode': _barcodeController.text,
        'manufacturer': _manufacturerController.text,
        'category': _selectedCategoryId,
        'requires_prescription': _requiresPrescription,
      };
      await _api.updateProduct(widget.productId, data);
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل المنتج بنجاح'), backgroundColor: kBlue),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: kBlue),
        );
      }
    }
  }

  Future<void> _updateStock(String action) async {
    final qty = int.tryParse(_stockQtyController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل كمية صحيحة'), backgroundColor: kBlue),
      );
      return;
    }
    try {
      await _api.updateStock(
        widget.productId,
        action,
        qty,
        _stockNoteController.text,
      );
      _stockQtyController.text = '1';
      _stockNoteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'add' ? 'تمت الإضافة بنجاح' : 'تم الخصم بنجاح'),
            backgroundColor: kBlue,
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: kBlue),
        );
      }
    }
  }

  Future<void> _deleteProduct() async {
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
        await _api.deleteProduct(widget.productId);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: kBlue),
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
          title: Text(_product?['name'] ?? 'تفاصيل المنتج'),
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          centerTitle: true,
          elevation: 0,
          actions: [
            if (!_editing)
              IconButton(
                icon: const Icon(Icons.edit, color: kWhite),
                onPressed: () => setState(() => _editing = true),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: kWhite),
              onPressed: _deleteProduct,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: kBlue))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: kBlack)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBlue,
                            foregroundColor: kWhite,
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: kBlue,
                    onRefresh: _loadAll,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_editing) _buildEditForm() else _buildProductInfo(),
                        const SizedBox(height: 24),
                        _buildStockUpdateSection(),
                        const SizedBox(height: 24),
                        _buildStockLogsSection(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final p = _product!;
    final stock = p['stock'] ?? 0;
    String stockLabel;
    if (stock == 0) {
      stockLabel = 'نفد من المخزون';
    } else if (stock <= 10) {
      stockLabel = 'مخزون منخفض ($stock)';
    } else {
      stockLabel = 'متاح ($stock)';
    }

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBlue, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p['name'] ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kBlack),
          ),
          const SizedBox(height: 12),
          _infoRow('القسم', p['category_name'] ?? 'غير محدد'),
          _infoRow('السعر', '${p['price']} جنيه'),
          _infoRow('المخزون', stockLabel),
          _infoRow('الباركود', p['barcode']?.isEmpty == true ? 'غير محدد' : (p['barcode'] ?? 'غير محدد')),
          _infoRow('الشركة المصنعة', p['manufacturer']?.isEmpty == true ? 'غير محدد' : (p['manufacturer'] ?? 'غير محدد')),
          _infoRow('يحتاج وصفة', p['requires_prescription'] == true ? 'نعم' : 'لا'),
          if (p['expiry_date'] != null)
            _infoRow('تاريخ الصلاحية', p['expiry_date']),
          if (p['description']?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            const Text('الوصف:', style: TextStyle(fontWeight: FontWeight.bold, color: kBlack)),
            const SizedBox(height: 4),
            Text(p['description'], style: const TextStyle(color: Colors.black54)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: kBlack)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBlue, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تعديل المنتج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBlue),
            ),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'اسم المنتج', required: true),
            const SizedBox(height: 12),
            _buildTextField(_priceController, 'السعر', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'القسم',
                labelStyle: const TextStyle(color: kBlack),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBlue, width: 2),
                ),
              ),
              dropdownColor: kWhite,
              style: const TextStyle(color: kBlack),
              items: _categories.map<DropdownMenuItem<int>>((cat) {
                return DropdownMenuItem<int>(
                  value: cat['id'],
                  child: Text(cat['name'], style: const TextStyle(color: kBlack)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              validator: (val) => val == null ? 'اختر القسم' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(_barcodeController, 'الباركود'),
            const SizedBox(height: 12),
            _buildTextField(_manufacturerController, 'الشركة المصنعة'),
            const SizedBox(height: 12),
            _buildTextField(_descController, 'الوصف', maxLines: 3),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('يحتاج وصفة طبية', style: TextStyle(color: kBlack)),
              value: _requiresPrescription,
              activeColor: kBlue,
              onChanged: (val) => setState(() => _requiresPrescription = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('حفظ التعديلات', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _populateForm(_product!);
                    setState(() => _editing = false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBlue,
                    side: const BorderSide(color: kBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  ),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: kBlack),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kBlack),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBlue, width: 2),
        ),
      ),
      validator: required
          ? (val) => (val == null || val.isEmpty) ? 'هذا الحقل مطلوب' : null
          : null,
    );
  }

  Widget _buildStockUpdateSection() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBlue, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحديث المخزون',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBlue),
          ),
          const SizedBox(height: 4),
          Text(
            'المخزون الحالي: ${_product?['stock'] ?? 0}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockQtyController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: kBlack),
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    labelStyle: const TextStyle(color: kBlack),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBlue, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stockNoteController,
            style: const TextStyle(color: kBlack),
            decoration: InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              labelStyle: const TextStyle(color: kBlack),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBlue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStock('add'),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateStock('remove'),
                  icon: const Icon(Icons.remove),
                  label: const Text('خصم'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBlue,
                    side: const BorderSide(color: kBlue, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سجل حركة المخزون',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBlue),
        ),
        const SizedBox(height: 12),
        if (_stockLogs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBlue.withAlpha(80)),
            ),
            child: const Text(
              'لا توجد حركات مخزون بعد',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...(_stockLogs.map((log) => _buildLogItem(log))),
      ],
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final isAdd = log['action'] == 'add';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBlue.withAlpha(80)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isAdd ? Icons.add : Icons.remove,
            color: kWhite,
            size: 20,
          ),
        ),
        title: Text(
          '${isAdd ? "إضافة" : "خصم"} ${log['quantity']} وحدة',
          style: const TextStyle(fontWeight: FontWeight.bold, color: kBlack),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log['note'] != null && log['note'].toString().isNotEmpty)
              Text(log['note'], style: const TextStyle(color: Colors.black54)),
            Text(
              _formatDate(log['created_at']),
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
