import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../services/firestore_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void fetchInvoices() {
    debugPrint('InvoiceProvider: Fetching invoices...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _firestoreService.getInvoices().listen(
        (invoices) {
          debugPrint('InvoiceProvider: Received ${invoices.length} invoices.');
          _invoices = invoices;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('InvoiceProvider Error: $e');
          _isLoading = false;
          _error = e.toString();
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('InvoiceProvider stream exception: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _firestoreService.addInvoice(invoice);
  }
}
