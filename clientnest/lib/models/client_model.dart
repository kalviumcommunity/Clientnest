import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String notes;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.notes,
    required this.createdAt,
  });

  factory Client.fromMap(Map<String, dynamic> map, String documentId) {
    return Client(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      company: map['company'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Client copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? notes,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
