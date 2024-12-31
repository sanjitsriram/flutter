import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Show the history of operations
Future<void> showHistory(BuildContext context, StateSetter setState) async {
  try {
    final response = await http.get(Uri.parse('http://192.168.56.1:3000/history'));

    if (response.statusCode == 200) {
      final List history = json.decode(response.body);

      // Show the updated history in the dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('History'),
          content: SingleChildScrollView(
            child: Column(
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
                          // Delete the history entry instantly
                          await deleteHistory(entry['id'], context, setState);
                          // After deleting, refresh the history
                          Navigator.pop(context);  // Close the history dialog immediately after delete
                          showHistory(context, setState);  // Refresh history by fetching again
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),  // Close only the dialog
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to load history');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching history: $e')));
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
            onPressed: () => Navigator.pop(context), // Close only the dialog
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              // Validate inputs before saving
              double? parsedNum1 = double.tryParse(num1Controller.text);
              double? parsedNum2 = double.tryParse(num2Controller.text);
              String operation = operationController.text;

              if (parsedNum1 == null || parsedNum2 == null || operation.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide valid input')));
                return;
              }

              // Update the operation via API
              await updateHistory(entry['id'], num1Controller.text, num2Controller.text, operationController.text, context, setState);
              Navigator.pop(context);  // Close the edit dialog
              showHistory(context, setState);  // Refresh the history by fetching again
            },
          ),
        ],
      );
    },
  );
}

// Update history item in the backend
Future<void> updateHistory(int id, String num1, String num2, String operation, BuildContext context, StateSetter setState) async {
  // Ensure that num1 and num2 are valid doubles before making the request
  double? parsedNum1 = double.tryParse(num1);
  double? parsedNum2 = double.tryParse(num2);

  if (parsedNum1 == null || parsedNum2 == null || operation.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide valid input')));
    return;
  }

  try {
    final response = await http.put(
      Uri.parse('http://192.168.56.1:3000/history/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'num1': parsedNum1,
        'num2': parsedNum2,
        'operation': operation,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated successfully')));
      // Optionally, refresh the history list after successful update
      setState(() {}); // Refresh the UI or data after update
    } else {
      throw Exception('Failed to update history');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating history: $e')));
  }
}

// Delete history item from the backend instantly without confirmation
Future<void> deleteHistory(int id, BuildContext context, StateSetter setState) async {
  try {
    final response = await http.delete(Uri.parse('http://192.168.56.1:3000/history/$id'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted successfully')));
      setState(() {}); // Refresh the UI after deletion
    } else {
      throw Exception('Failed to delete history');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting history: $e')));
  }
}
