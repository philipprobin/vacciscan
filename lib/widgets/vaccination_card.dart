import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/vaccination.dart';

class VaccinationCard extends StatelessWidget {
  final Vaccination vaccination;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VaccinationCard({
    super.key,
    required this.vaccination,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15.0),
        leading: const CircularIndicator(),
        title: Text(
          vaccination.brand,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vaccination.against),
            const SizedBox(height: 4.0),
            Text(
              'Date: ${vaccination.date}',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

class CircularIndicator extends StatelessWidget {
  const CircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.2),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
