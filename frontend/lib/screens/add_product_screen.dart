import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _manufacturerController = TextEditingController();

  List<dynamic> _categories = [];
  int? _selectedCategoryId;
  DateTime? _expiryDate;
  bool _requiresPrescription = false;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _api.getCategories();
      setState(() {
        _categories = categories;
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

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kBlue,
              onPrimary: kWhite,
              onSurface: kBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'category': _selectedCategoryId,
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock': _stockController.text.trim().isNotEmpty
            ? int.parse(_stockController.text.trim())
            : 0,
        'barcode': _barcodeController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'requires_prescription': _requiresPrescription,
      };
      if (_expiryDate != null) {
        data['expiry_date'] =
            '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}';
      }

      await _api.createProduct(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المنتج بنجاح'),
            backgroundColor: kBlue,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ المنتج: $e'),
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
          title: const Text('إضافة منتج جديد',
              style: TextStyle(color: kWhite)),
          backgroundColor: kBlue,
          iconTheme: const IconThemeData(color: kWhite),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kBlue),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('اسم المنتج *'),
                        style: const TextStyle(color: kBlack),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'اسم المنتج مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category dropdown
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: _inputDecoration('القسم *'),
                        dropdownColor: kWhite,
                        style: const TextStyle(color: kBlack),
                        items: _categories.map<DropdownMenuItem<int>>((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'],
                            child: Text(cat['name'] ?? '',
                                style: const TextStyle(color: kBlack)),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                        validator: (v) {
                          if (v == null) return 'القسم مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('الوصف'),
                        style: const TextStyle(color: kBlack),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Price
                      TextFormField(
                        controller: _priceController,
                        decoration: _inputDecoration('السعر *'),
                        style: const TextStyle(color: kBlack),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'السعر مطلوب';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'أدخل سعر صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Stock
                      TextFormField(
                        controller: _stockController,
                        decoration: _inputDecoration('الكمية'),
                        style: const TextStyle(color: kBlack),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Barcode
                      TextFormField(
                        controller: _barcodeController,
                        decoration: _inputDecoration('الباركود'),
                        style: const TextStyle(color: kBlack),
                      ),
                      const SizedBox(height: 16),

                      // Manufacturer
                      TextFormField(
                        controller: _manufacturerController,
                        decoration: _inputDecoration('الشركة المصنعة'),
                        style: const TextStyle(color: kBlack),
                      ),
                      const SizedBox(height: 16),

                      // Expiry date
                      InkWell(
                        onTap: _pickExpiryDate,
                        child: InputDecorator(
                          decoration: _inputDecoration('تاريخ الصلاحية'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _expiryDate != null
                                    ? '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}'
                                    : 'اختر تاريخ الصلاحية',
                                style: TextStyle(
                                  color: _expiryDate != null
                                      ? kBlack
                                      : Colors.black54,
                                ),
                              ),
                              const Icon(Icons.calendar_today,
                                  color: kBlue, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Requires prescription switch
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: kBlue),
                          borderRadius: BorderRadius.circular(4),
                          color: kWhite,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('يحتاج روشتة',
                                style: TextStyle(color: kBlack, fontSize: 16)),
                            Switch(
                              value: _requiresPrescription,
                              onChanged: (v) =>
                                  setState(() => _requiresPrescription = v),
                              activeColor: kBlue,
                              inactiveTrackColor: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProduct,
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
                              : const Text('حفظ المنتج',
                                  style: TextStyle(
                                      fontSize: 18, color: kWhite)),
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
