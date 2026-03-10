import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/invoice_model.dart';

class DummyDataService {
  static Future<void> seedDummyData(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('Cannot seed data: No authenticated user.');
      // Show snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to seed data.')),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeding dummy data...')),
      );
    }

    final db = FirebaseFirestore.instance;

    // Create Dummy Clients
    final clients = [
      Client(
        id: '',
        userId: uid,
        name: 'TechFlow Solutions',
        email: 'contact@techflow.com',
        phone: '+1 555-0100',
        company: 'TechFlow Inc.',
        notes: 'Tech startup with ongoing web projects.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Client(
        id: '',
        userId: uid,
        name: 'Sarah Jenkins',
        email: 'sarah.j@innovate.net',
        phone: '+44 20 7946 0958',
        company: 'Innovate Network',
        notes: 'Mobile app development for new HR system.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Client(
        id: '',
        userId: uid,
        name: 'GreenEarth Co.',
        email: 'hello@greenearth.org',
        phone: '+61 2 9876 5432',
        company: 'GreenEarth',
        notes: 'Non-profit organization focusing on sustainability.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    List<String> clientIds = [];
    for (var client in clients) {
      final map = client.toMap();
      map['userId'] = uid;
      final docRef = await db.collection('clients').add(map);
      clientIds.add(docRef.id);
    }

    // Create Dummy Projects
    final projects = [
      Project(
        id: '',
        userId: uid,
        clientId: clientIds[0],
        clientName: clients[0].name,
        title: 'Website Redesign',
        description: 'Complete overhaul of the existing corporate website with Next.js and TailwindCSS.',
        status: ProjectStatus.active,
        budget: 4500.0,
        deadline: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Project(
        id: '',
        userId: uid,
        clientId: clientIds[1],
        clientName: clients[1].name,
        title: 'Mobile App MVP',
        description: 'Flutter-based MVP for the new internal HR system.',
        status: ProjectStatus.lead,
        budget: 8000.0,
        deadline: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Project(
        id: '',
        userId: uid,
        clientId: clientIds[2],
        clientName: clients[2].name,
        title: 'SEO Audit',
        description: 'Comprehensive SEO audit and performance optimization report.',
        status: ProjectStatus.completed,
        budget: 1200.0,
        deadline: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    List<String> projectIds = [];
    for (var project in projects) {
      final map = project.toMap();
      map['userId'] = uid;
      final docRef = await db.collection('projects').add(map);
      projectIds.add(docRef.id);

      // Create dummy tasks for this project
      final tasks = [
        Task(
          id: '',
          projectId: docRef.id,
          userId: uid,
          title: 'Initial Wireframes',
          isCompleted: true,
          priority: 'High',
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Task(
          id: '',
          projectId: docRef.id,
          userId: uid,
          title: 'Database Schema Design',
          isCompleted: false,
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Task(
          id: '',
          projectId: docRef.id,
          userId: uid,
          title: 'Client Review Meeting',
          isCompleted: false,
          priority: 'Medium',
          dueDate: DateTime.now().add(const Duration(days: 4)),
          createdAt: DateTime.now(),
        ),
      ];

      for (var task in tasks) {
        final taskMap = task.toMap();
        taskMap['userId'] = uid;
        await db.collection('tasks').add(taskMap);
      }
    }

    // Create Dummy Invoices
    final invoices = [
      Invoice(
        id: '',
        userId: uid,
        clientId: clientIds[0],
        clientName: clients[0].name,
        projectId: projectIds[0],
        invoiceNumber: 'INV-001',
        amount: 2250.0,
        status: 'Paid',
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          InvoiceItem(description: 'Initial Deposit (50%)', quantity: 1, unitPrice: 2250.0),
        ],
      ),
      Invoice(
        id: '',
        userId: uid,
        clientId: clientIds[0],
        clientName: clients[0].name,
        projectId: projectIds[0],
        invoiceNumber: 'INV-002',
        amount: 2250.0,
        status: 'Pending',
        issueDate: DateTime.now().add(const Duration(days: 10)),
        dueDate: DateTime.now().add(const Duration(days: 24)),
        items: [
          InvoiceItem(description: 'Final Milestone (50%)', quantity: 1, unitPrice: 2250.0),
        ],
      ),
      Invoice(
        id: '',
        userId: uid,
        clientId: clientIds[2],
        clientName: clients[2].name,
        projectId: projectIds[2],
        invoiceNumber: 'INV-003',
        amount: 1200.0,
        status: 'Paid',
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 9)),
        items: [
          InvoiceItem(description: 'SEO Audit Report', quantity: 1, unitPrice: 800.0),
          InvoiceItem(description: 'Performance Optimization', quantity: 1, unitPrice: 400.0),
        ],
      ),
    ];

    for (var invoice in invoices) {
      final map = invoice.toMap();
      map['userId'] = uid;
      await db.collection('invoices').add(map);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dummy Data Seeded Successfully!')),
      );
    }
  }
}
