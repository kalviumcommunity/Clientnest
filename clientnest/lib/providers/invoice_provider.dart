import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../services/firestore_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Invoice>>? _subscription;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Computed financial totals (updated automatically as stream fires)
  double get totalIncome => _invoices
      .where((inv) => inv.status == 'Paid')
      .fold(0.0, (sum, inv) => sum + inv.amount);

  double get totalPending => _invoices
      .where((inv) => inv.status != 'Paid')
      .fold(0.0, (sum, inv) => sum + inv.amount);

  InvoiceProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      fetchInvoices();
    }
  }

  void fetchInvoices() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _firestoreService.getInvoices().listen(
        (invoices) {
          _invoices = invoices;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('InvoiceProvider Error: $e');
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _invoices = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await _firestoreService.addInvoice(invoice);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      await _firestoreService.updateInvoice(invoice);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestoreService.deleteInvoice(invoiceId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
