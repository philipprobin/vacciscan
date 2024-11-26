import 'package:flutter/material.dart';

import '../models/vaccination.dart';
import '../services/shared_prefs.dart';

class VaccinationEditDialog extends StatefulWidget {
  final Vaccination vaccination;

  const VaccinationEditDialog({super.key, required this.vaccination});

  @override
  _VaccinationEditDialogState createState() => _VaccinationEditDialogState();
}

class _VaccinationEditDialogState extends State<VaccinationEditDialog> {
  late TextEditingController brandController;
  late TextEditingController againstController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    brandController = TextEditingController(text: widget.vaccination.brand);
    againstController = TextEditingController(text: widget.vaccination.against);
    dateController = TextEditingController(text: widget.vaccination.date);
  }

  @override
  void dispose() {
    brandController.dispose();
    againstController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Vaccination'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: brandController,
            decoration: const InputDecoration(labelText: 'Brand'),
          ),
          TextField(
            controller: againstController,
            decoration: const InputDecoration(labelText: 'Against'),
          ),
          TextField(
            controller: dateController,
            decoration: const InputDecoration(labelText: 'Date'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Vaccination updatedVaccination = Vaccination(
              brand: brandController.text,
              against: againstController.text,
              date: dateController.text,
            );

            // Update the vaccination in SharedPreferences
            await SharedPrefs.updateVaccination(widget.vaccination, updatedVaccination);

            // Return the updated vaccination
            Navigator.of(context).pop(updatedVaccination);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
