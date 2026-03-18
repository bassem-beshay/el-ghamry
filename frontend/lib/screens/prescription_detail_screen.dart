import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final int prescriptionId;

  const PrescriptionDetailScreen({super.key, required this.prescriptionId});

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  final _api = ApiService();

  Map<String, dynamic>? _prescription;
  bool _isLoading = true;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _loadPrescription();
  }

  Future<void> _loadPrescription() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getPrescription(widget.prescriptionId);
      setState(() {
        _prescription = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الروشتة: $e'),
            backgroundColor: kBlue,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(int itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: kWhite,
          title: const Text('تأكيد الحذف',
              style: TextStyle(color: kBlack)),
          content: const Text('هل أنت متأكد من حذف هذا الصنف؟',
              style: TextStyle(color: kBlack)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: kBlack)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف',
                  style: TextStyle(color: kBlue)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      try {
        await _api.removePrescriptionItem(widget.prescriptionId, itemId);
        _changed = true;
        _loadPrescription();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الصنف'),
              backgroundColor: kBlue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف الصنف: $e'),
              backgroundColor: kBlue,
            ),
          );
        }
      }
    }
  }

  Future<void> _addItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _AddItemDialog(),
    );
    if (result != null) {
      try {
        await _api.addPrescriptionItem(widget.prescriptionId, result);
        _changed = true;
        _loadPrescription();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الصنف'),
              backgroundColor: kBlue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إضافة الصنف: $e'),
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
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop && _changed) {
            Navigator.of(context);
          }
        },
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: const Text('تفاصيل الروشتة',
                style: TextStyle(color: kWhite)),
            backgroundColor: kBlue,
            iconTheme: const IconThemeData(color: kWhite),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, _changed),
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kBlue))
              : _prescription == null
                  ? const Center(
                      child: Text('لا توجد بيانات',
                          style: TextStyle(
                              color: Colors.black54, fontSize: 18)),
                    )
                  : Column(
                      children: [
                        // Patient info
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow(Icons.person, 'المريض',
                                  _prescription!['patient_name'] ?? '-'),
                              const SizedBox(height: 8),
                              _infoRow(Icons.phone, 'الهاتف',
                                  _prescription!['patient_phone'] ?? '-'),
                              const SizedBox(height: 8),
                              _infoRow(Icons.medical_services, 'الطبيب',
                                  _prescription!['doctor_name'] ?? '-'),
                              if (_prescription!['notes'] != null &&
                                  (_prescription!['notes'] as String)
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _infoRow(Icons.note, 'ملاحظات',
                                    _prescription!['notes']),
                              ],
                            ],
                          ),
                        ),

                        // Items header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الأصناف',
                                style: TextStyle(
                                  color: kBlack,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add, color: kBlue),
                                label: const Text('إضافة صنف',
                                    style: TextStyle(color: kBlue)),
                              ),
                            ],
                          ),
                        ),

                        // Items list
                        Expanded(
                          child: _buildItemsList(),
                        ),

                        // Total
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: kBlue,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الإجمالي',
                                style: TextStyle(
                                  color: kWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_prescription!['total_price'] ?? '0'} جنيه',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kBlue, size: 20),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                color: Colors.black54, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value, style: const TextStyle(color: kBlack)),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    final items = _prescription!['items'] as List? ?? [];
    if (items.isEmpty) {
      return const Center(
        child: Text('لا توجد أصناف',
            style: TextStyle(color: Colors.black54, fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: Key('item_${item['id']}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: kBlue,
            child: const Icon(Icons.delete, color: kWhite),
          ),
          confirmDismiss: (_) async {
            await _removeItem(item['id']);
            return false;
          },
          child: Card(
            color: kWhite,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: kBlue, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product_name'] ?? item['medicine_name'] ?? '-',
                    style: const TextStyle(
                      color: kBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _itemDetail('الكمية', '${item['quantity'] ?? '-'}'),
                      const SizedBox(width: 16),
                      _itemDetail('الجرعة', item['dosage'] ?? '-'),
                      const SizedBox(width: 16),
                      _itemDetail('المدة', item['duration'] ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السعر: ${item['price'] ?? '0'} جنيه',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'الإجمالي: ${item['total'] ?? item['total_price'] ?? '0'} جنيه',
                        style: const TextStyle(
                          color: kBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _itemDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
        Text(value, style: const TextStyle(color: kBlack)),
      ],
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();

  List<dynamic> _products = [];
  Map<String, dynamic>? _selectedProduct;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _products = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final data = await _api.getProducts(search: query);
      setState(() {
        _products = data is List ? data : (data['results'] ?? []);
        _isSearching = false;
      });
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: kWhite,
        title: const Text('إضافة صنف',
            style: TextStyle(color: kBlack)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product search
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: kBlack),
                  decoration: InputDecoration(
                    labelText: 'بحث عن منتج',
                    labelStyle: const TextStyle(color: kBlack),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue, width: 2),
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: kBlue, strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search, color: kBlue),
                  ),
                  onChanged: _searchProducts,
                ),

                if (_products.isNotEmpty && _selectedProduct == null)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBlue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _products.length,
                      itemBuilder: (_, i) {
                        final p = _products[i];
                        return ListTile(
                          dense: true,
                          title: Text(p['name'] ?? '',
                              style: const TextStyle(color: kBlack)),
                          subtitle: Text('${p['price'] ?? 0} جنيه',
                              style: const TextStyle(color: Colors.black54)),
                          onTap: () {
                            setState(() {
                              _selectedProduct = p;
                              _searchController.text = p['name'] ?? '';
                              _products = [];
                            });
                          },
                        );
                      },
                    ),
                  ),

                if (_selectedProduct != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedProduct!['name'] ?? '',
                            style: const TextStyle(
                                color: kBlue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: kBlack, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedProduct = null;
                              _searchController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  style: const TextStyle(color: kBlack),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'الكمية',
                    labelStyle: TextStyle(color: kBlack),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dosageController,
                  style: const TextStyle(color: kBlack),
                  decoration: const InputDecoration(
                    labelText: 'الجرعة',
                    labelStyle: TextStyle(color: kBlack),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _durationController,
                  style: const TextStyle(color: kBlack),
                  decoration: const InputDecoration(
                    labelText: 'المدة',
                    labelStyle: TextStyle(color: kBlack),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlue, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(color: kBlack)),
          ),
          ElevatedButton(
            onPressed: _selectedProduct == null
                ? null
                : () {
                    Navigator.pop(context, {
                      'product': _selectedProduct!['id'],
                      'quantity': int.tryParse(
                              _quantityController.text.trim()) ??
                          1,
                      'dosage': _dosageController.text.trim(),
                      'duration': _durationController.text.trim(),
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              foregroundColor: kWhite,
            ),
            child: const Text('إضافة', style: TextStyle(color: kWhite)),
          ),
        ],
      ),
    );
  }
}
