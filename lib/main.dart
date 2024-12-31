import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'secpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // Function to check server response when the user presses the "Click to Proceed" button
  Future<void> checkProceed(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:3000/checkProceed'),
      );

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData.contains('1')) {
          // If the server returns 1, navigate to the second page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondPage()),
          );
        } else {
          // If the server returns 0, show "Try Again" dialog
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
      } else {
        // Handle non-200 responses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Server Error'),
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
