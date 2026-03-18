import 'package:flutter/material.dart';
import '../main.dart' show kBlue, kWhite, kBlack;
import '../services/api_service.dart';
import 'prescription_detail_screen.dart';
import 'add_prescription_screen.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();

  List<dynamic> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getPrescriptions(search: search);
      setState(() {
        _prescriptions = data is List ? data : (data['results'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الروشتات: $e'),
            backgroundColor: kBlue,
          ),
        );
      }
    }
  }

  Future<void> _deletePrescription(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: kWhite,
          title: const Text('تأكيد الحذف',
              style: TextStyle(color: kBlack)),
          content: const Text('هل أنت متأكد من حذف هذه الروشتة؟',
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
        await _api.deletePrescription(id);
        _loadPrescriptions(search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الروشتة بنجاح'),
              backgroundColor: kBlue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف الروشتة: $e'),
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
          title: const Text('الروشتات',
              style: TextStyle(color: kWhite)),
          backgroundColor: kBlue,
          iconTheme: const IconThemeData(color: kWhite),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: kBlack),
                decoration: InputDecoration(
                  hintText: 'بحث عن روشتة...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: kBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: kBlack),
                          onPressed: () {
                            _searchController.clear();
                            _loadPrescriptions();
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: kBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: kBlue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: kWhite,
                ),
                onChanged: (value) {
                  setState(() {});
                  _loadPrescriptions(
                      search: value.trim().isEmpty ? null : value.trim());
                },
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kBlue))
                  : _prescriptions.isEmpty
                      ? const Center(
                          child: Text('لا توجد روشتات',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 18)),
                        )
                      : RefreshIndicator(
                          color: kBlue,
                          onRefresh: () => _loadPrescriptions(
                              search:
                                  _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim()),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _prescriptions.length,
                            itemBuilder: (context, index) {
                              final rx = _prescriptions[index];
                              return Dismissible(
                                key: Key('rx_${rx['id']}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  color: kBlue,
                                  child:
                                      const Icon(Icons.delete, color: kWhite),
                                ),
                                confirmDismiss: (_) async {
                                  await _deletePrescription(rx['id']);
                                  return false;
                                },
                                child: Card(
                                  color: kWhite,
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: kBlue, width: 0.5),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PrescriptionDetailScreen(
                                                  prescriptionId: rx['id']),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadPrescriptions(
                                            search: _searchController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _searchController.text
                                                    .trim());
                                      }
                                    },
                                    title: Text(
                                      rx['patient_name'] ?? 'بدون اسم',
                                      style: const TextStyle(
                                        color: kBlack,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.medical_services,
                                                color: kBlue, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              rx['doctor_name'] ?? '-',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: kBlue, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              rx['date'] ?? rx['created_at'] ?? '-',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.medication,
                                                    color: kBlue,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${rx['items_count'] ?? (rx['items'] is List ? (rx['items'] as List).length : 0)} أصناف',
                                                  style: const TextStyle(
                                                      color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${rx['total_price'] ?? '0'} جنيه',
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
                          ),
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddPrescriptionScreen()),
            );
            if (result == true) {
              _loadPrescriptions();
            }
          },
          backgroundColor: kBlue,
          child: const Icon(Icons.add, color: kWhite),
        ),
      ),
    );
  }
}
