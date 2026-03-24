import 'dart:async';
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';

class ClientProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Client>>? _subscription;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void fetchClients() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _firestoreService.getClients().listen(
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
    _clients = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
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
