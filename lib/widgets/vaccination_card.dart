import 'package:flutter/material.dart';
import '../models/vaccination.dart';
import '../util/lang_converter.dart';

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

  bool _isDateValid(String date) {
    // Match format DD.MM.YYYY
    final dateRegExp = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
    if (!dateRegExp.hasMatch(date)) return false;

    // Split and validate ranges
    final parts = date.split('.');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return false;

    if (day < 1 || day > 31 || month < 1 || month > 12) return false;

    // Additional: Ensure the year is reasonable
    final currentYear = DateTime.now().year;
    if (year > currentYear || year < 1900) return false;

    return true;
  }

  bool _isAgainstValid(String against) {
    final validVaccines = LangConverter().english;
    return validVaccines.contains(against);
  }

  @override
  Widget build(BuildContext context) {
    final isDateValid = _isDateValid(vaccination.date);
    final isAgainstValid = _isAgainstValid(vaccination.against);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15.0),
        leading: CircularIndicator(
          color: isDateValid && isAgainstValid ? Colors.green : Colors.red,
        ),

        title: Text(
          vaccination.brand,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(vaccination.against),
                if (!isAgainstValid) ...[
                  const SizedBox(width: 8.0),
                  const Icon(Icons.warning, color: Colors.red, size: 16.0),
                ],
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Text(
                  'Date: ${vaccination.date}',
                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                if (!isDateValid) ...[
                  const SizedBox(width: 8.0),
                  const Icon(Icons.warning, color: Colors.red, size: 16.0),
                ],
              ],
            ),
            if (!isAgainstValid || !isDateValid)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please edit this card to fix the errors.',
                  style: TextStyle(fontSize: 12.0, color: Colors.red),
                ),
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
  final Color color;

  const CircularIndicator({super.key, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}
