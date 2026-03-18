import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _items = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMedicine() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _MedicineSearchDialog(),
    );
    if (result != null) {
      setState(() => _items.add(result));
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف صنف واحد على الأقل'),
          backgroundColor: kBlue,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'patient_name': _patientNameController.text.trim(),
        'patient_phone': _patientPhoneController.text.trim(),
        'doctor_name': _doctorNameController.text.trim(),
        'notes': _notesController.text.trim(),
        'items': _items
            .map((item) => {
                  'product': item['product_id'],
                  'quantity': item['quantity'],
                  'dosage': item['dosage'],
                  'duration': item['duration'],
                })
            .toList(),
      };

      await _api.createPrescription(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الروشتة بنجاح'),
            backgroundColor: kBlue,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الروشتة: $e'),
            backgroundColor: kBlue,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kBlack),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBlue),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBlue, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBlack),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBlue, width: 2),
      ),
      filled: true,
      fillColor: kWhite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: const Text('روشتة جديدة',
              style: TextStyle(color: kWhite)),
          backgroundColor: kBlue,
          iconTheme: const IconThemeData(color: kWhite),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Patient info section
                const Text(
                  'بيانات المريض',
                  style: TextStyle(
                    color: kBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _patientNameController,
                  decoration: _inputDecoration('اسم المريض *'),
                  style: const TextStyle(color: kBlack),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'اسم المريض مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _patientPhoneController,
                  decoration: _inputDecoration('رقم الهاتف'),
                  style: const TextStyle(color: kBlack),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _doctorNameController,
                  decoration: _inputDecoration('اسم الطبيب'),
                  style: const TextStyle(color: kBlack),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _notesController,
                  decoration: _inputDecoration('ملاحظات'),
                  style: const TextStyle(color: kBlack),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Medicines section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الأدوية',
                      style: TextStyle(
                        color: kBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addMedicine,
                      icon: const Icon(Icons.add, color: kWhite, size: 18),
                      label: const Text('إضافة دواء',
                          style: TextStyle(color: kWhite)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: kWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBlue, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'لم يتم إضافة أدوية بعد',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        color: kWhite,
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: kBlue, width: 0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['product_name'] ?? '-',
                                      style: const TextStyle(
                                        color: kBlack,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'الكمية: ${item['quantity']}  |  الجرعة: ${item['dosage'].toString().isEmpty ? '-' : item['dosage']}  |  المدة: ${item['duration'].toString().isEmpty ? '-' : item['duration']}',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13),
                                    ),
                                    if (item['price'] != null)
                                      Text(
                                        'السعر: ${item['price']} جنيه',
                                        style: const TextStyle(
                                            color: kBlue, fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: kBlue),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: kWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('حفظ الروشتة',
                            style:
                                TextStyle(fontSize: 18, color: kWhite)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicineSearchDialog extends StatefulWidget {
  const _MedicineSearchDialog();

  @override
  State<_MedicineSearchDialog> createState() => _MedicineSearchDialogState();
}

class _MedicineSearchDialogState extends State<_MedicineSearchDialog> {
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
        title: const Text('إضافة دواء',
            style: TextStyle(color: kBlack)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: kBlack),
                  decoration: InputDecoration(
                    labelText: 'بحث عن دواء',
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

                // Search results
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
                              style:
                                  const TextStyle(color: Colors.black54)),
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
                  const SizedBox(height: 8),
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
                          icon: const Icon(Icons.close,
                              color: kBlack, size: 18),
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
                      'product_id': _selectedProduct!['id'],
                      'product_name': _selectedProduct!['name'],
                      'price': _selectedProduct!['price'],
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
            child:
                const Text('إضافة', style: TextStyle(color: kWhite)),
          ),
        ],
      ),
    );
  }
}
