import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';

class ClientProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Client> _clients = []; // Sorted/Filtered list
  List<Client> _allClients = []; // Unfiltered list for metrics
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Client>>? _subscription;
  StreamSubscription<List<Client>>? _totalSubscription;

  // Sorting State
  String _sortBy = 'name';
  bool _isDescending = false;

  List<Client> get clients => _clients;
  List<Client> get allClients => _allClients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;
  bool get isDescending => _isDescending;

  ClientProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      _initTotalStream();
      fetchClients();
    }
  }

  void _initTotalStream() {
    _totalSubscription?.cancel();
    _totalSubscription = _firestoreService.getClients().listen(
      (clients) {
        _allClients = clients;
        notifyListeners();
      },
      onError: (e) => debugPrint('Total Clients Stream Error: $e'),
    );
  }

  void setSort(String field, {bool? descending}) {
    _sortBy = field;
    if (descending != null) _isDescending = descending;
    fetchClients();
  }

  void toggleDirection() {
    _isDescending = !_isDescending;
    fetchClients();
  }

  void fetchClients() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _firestoreService.getClients(
        sortBy: _sortBy,
        descending: _isDescending,
      ).listen(
        (clients) {
          _clients = clients;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('ClientProvider Error: $e');
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
    _clients = [];
    _allClients = [];
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

  Future<void> addClient(Client client) async {
    try {
      await _firestoreService.addClient(client);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      await _firestoreService.updateClient(client);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _firestoreService.deleteClient(clientId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
