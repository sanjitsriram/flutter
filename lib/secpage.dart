import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history.dart';  // Import the history functionality

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final num1Controller = TextEditingController();
  final num2Controller = TextEditingController();
  String result = '';
  String operation = '';  // To store selected operation

  // Function to send data to the backend for calculation
  Future<void> calculate() async {
    final num1 = double.tryParse(num1Controller.text);
    final num2 = double.tryParse(num2Controller.text);

    if (num1 == null || num2 == null || operation.isEmpty) {
      // Optionally show an alert for invalid input
      setState(() {
        result = 'Invalid input or operation.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:3000/calculate'),  // Ensure this URL is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'num1': num1,
          'num2': num2,
          'operation': operation,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result'] != null) {
          setState(() {
            result = jsonResponse['result'].toString();
          });
        } else {
          setState(() {
            result = 'No result found in response.';
          });
        }
      } else {
        setState(() {
          result = 'Error during API call: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error during calculation: $e';
      });
    }
  }

  // Set the operation and reset the result
  void setOperation(String op) {
    setState(() {
      operation = op;  // Update the selected operation
      result = '';  // Reset the result when the operation changes
    });
  }

  // Show history functionality modified to pass `setState`
  void showHistoryDialog() {
    showHistory(context, setState);  // Pass setState to the history function
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: showHistoryDialog, // Call the modified function to show history
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Input fields for the numbers
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter first number'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter second number'),
            ),
            SizedBox(height: 20),
            // Operation selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => setOperation('+'),
                  child: Text('Add'),
                ),
                ElevatedButton(
                  onPressed: () => setOperation('-'),
                  child: Text('Subtract'),
                ),
                ElevatedButton(
                  onPressed: () => setOperation('*'),
                  child: Text('Multiply'),
                ),
                ElevatedButton(
                  onPressed: () => setOperation('/'),
                  child: Text('Divide'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Calculate button
            ElevatedButton(
              onPressed: calculate,
              child: Text('Calculate'),
            ),
            SizedBox(height: 20),
            // Display the result
            if (result.isNotEmpty) Text('Result: $result'),
          ],
        ),
      ),
    );
  }
}
