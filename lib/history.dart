// history.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Show the history of operations
Future<void> showHistory(BuildContext context, StateSetter setState) async {
  final response = await http.get(Uri.parse('http://192.168.19.132:3000/history'));
  if (response.statusCode == 200) {
    final List history = json.decode(response.body);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('History'),
        content: Column(
          children: history.map<Widget>((entry) {
            return ListTile(
              title: Text('${entry['num1']} ${entry['operation']} ${entry['num2']} = ${entry['result']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Open the edit dialog with the current values
                      _editHistory(context, entry, setState);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await deleteHistory(entry['id'], context, setState);
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Show the edit dialog to update history
Future<void> _editHistory(BuildContext context, Map entry, StateSetter setState) async {
  TextEditingController num1Controller = TextEditingController(text: entry['num1'].toString());
  TextEditingController num2Controller = TextEditingController(text: entry['num2'].toString());
  TextEditingController operationController = TextEditingController(text: entry['operation']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Operation'),
        content: Column(
          children: [
            TextField(
              controller: num1Controller,
              decoration: InputDecoration(labelText: 'Number 1'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: num2Controller,
              decoration: InputDecoration(labelText: 'Number 2'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: operationController,
              decoration: InputDecoration(labelText: 'Operation (+, -, *, /)'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              // Update the operation via API
              await updateHistory(entry['id'], num1Controller.text, num2Controller.text, operationController.text, context, setState);
            },
          ),
        ],
      );
    },
  );
}

// Update history item in the backend
Future<void> updateHistory(int id, String num1, String num2, String operation, BuildContext context, StateSetter setState) async {
  final response = await http.put(
    Uri.parse('http://192.168.19.132:3000/history/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'num1': double.tryParse(num1),
      'num2': double.tryParse(num2),
      'operation': operation,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated successfully')));
    Navigator.pop(context); // Close the dialog
    setState(() {}); // Refresh the history list
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update')));
  }
}

// Delete history item from server
Future<void> deleteHistory(int id, BuildContext context, StateSetter setState) async {
  final response = await http.delete(Uri.parse('http://192.168.19.132:3000/history/$id'));
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted successfully')));
    setState(() {}); // Refresh the history list
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete')));
  }
}
