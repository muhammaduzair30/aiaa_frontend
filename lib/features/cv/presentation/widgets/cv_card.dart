import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cv_entity.dart';

class CVCard extends StatelessWidget {
  final CVEntity cv;
  final VoidCallback onDelete;

  const CVCard({super.key, required this.cv, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.description, size: 40, color: Colors.blue),
        title: Text(
          cv.originalFilename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Uploaded: ${DateFormat('MMM dd, yyyy').format(cv.createdAt)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text("Are you sure you wish to delete this CV?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDelete();
                      },
                      child: const Text("DELETE"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
