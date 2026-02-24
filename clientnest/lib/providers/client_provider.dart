import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';

class ClientProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void fetchClients() {
    debugPrint('ClientProvider: Fetching clients...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    _firestoreService.getClients().listen(
      (clients) {
        debugPrint('ClientProvider: Received ${clients.length} clients.');
        _clients = clients;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ClientProvider Error: $e');
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addClient(Client client) async {
    await _firestoreService.addClient(client);
  }

  Future<void> updateClient(Client client) async {
    await _firestoreService.updateClient(client);
  }
}
