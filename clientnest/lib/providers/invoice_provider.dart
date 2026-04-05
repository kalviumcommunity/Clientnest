import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../services/firestore_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Invoice> _invoices = []; // Filtered list for UI
  List<Invoice> _allInvoices = []; // Unfiltered list for metrics
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Invoice>>? _subscription;
  StreamSubscription<List<Invoice>>? _totalSubscription;

  // Query State
  String? _filterStatus;
  String _sortBy = 'issueDate';
  bool _isDescending = true;

  List<Invoice> get invoices => _invoices;
  List<Invoice> get allInvoices => _allInvoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterStatus => _filterStatus;
  String get sortBy => _sortBy;
  bool get isDescending => _isDescending;

  /// Computed financial totals (updated from unfiltered data)
  double get totalIncome => _allInvoices
      .where((inv) => inv.status == 'Paid')
      .fold(0.0, (sum, inv) => sum + inv.amount);

  double get totalPending => _allInvoices
      .where((inv) => inv.status != 'Paid')
      .fold(0.0, (sum, inv) => sum + inv.amount);

  InvoiceProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      _initTotalStream();
      fetchInvoices();
    }
  }

  void _initTotalStream() {
    _totalSubscription?.cancel();
    _totalSubscription = _firestoreService.getInvoices().listen(
      (invoices) {
        _allInvoices = invoices;
        notifyListeners();
      },
      onError: (e) => debugPrint('Total Invoices Stream Error: $e'),
    );
  }

  void setFilter(String? status) {
    if (_filterStatus == status) return;
    _filterStatus = status;
    fetchInvoices();
  }

  void setSort(String field, {bool? descending}) {
    _sortBy = field;
    if (descending != null) _isDescending = descending;
    fetchInvoices();
  }

  void toggleDirection() {
    _isDescending = !_isDescending;
    fetchInvoices();
  }

  void fetchInvoices() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _firestoreService.getInvoices(
        status: _filterStatus,
        sortBy: _sortBy,
        descending: _isDescending,
      ).listen(
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
    _totalSubscription?.cancel();
    _totalSubscription = null;
    _invoices = [];
    _allInvoices = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _totalSubscription?.cancel();
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
