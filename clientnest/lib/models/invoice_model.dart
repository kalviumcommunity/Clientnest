import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}

class Invoice {
  final String id;
  final String userId;
  final String clientId;
  final String clientName;
  final String projectId;
  final String invoiceNumber;
  final double amount;
  final String status;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.clientName,
    required this.projectId,
    required this.invoiceNumber,
    required this.amount,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.items,
  });

  factory Invoice.fromMap(Map<String, dynamic> map, String documentId) {
    return Invoice(
      id: documentId,
      userId: map['userId'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      projectId: map['projectId'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'unpaid',
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      items: (map['items'] as List? ?? [])
          .map((item) => InvoiceItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'clientName': clientName,
      'projectId': projectId,
      'invoiceNumber': invoiceNumber,
      'amount': amount,
      'status': status,
      'issueDate': Timestamp.fromDate(issueDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'items': items.map((i) => i.toMap()).toList(),
    };
  }

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>? ?? {};
    return Invoice.fromMap(map, doc.id);
  }

  Invoice copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? clientName,
    String? projectId,
    String? invoiceNumber,
    double? amount,
    String? status,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      projectId: projectId ?? this.projectId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
    );
  }
}
