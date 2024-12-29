// main.dart
import 'package:flutter/material.dart';
import 'second_page.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  // Check server response when the user presses the "Click to Proceed" button
  Future<void> checkProceed(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.19.132:3000/checkProceed'),
      );

      if (response.statusCode == 200) {
        // If the server returns 200, navigate to the second page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SecondPage()),
        );
      } else {
        // Handle non-200 responses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Try Again'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Catch any errors from the HTTP request
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => checkProceed(context),
          child: Text('Click to Proceed'),
        ),
      ),
    );
  }
}
