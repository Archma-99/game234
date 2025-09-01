import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _search() {
    if (_cityController.text.isNotEmpty) {
      Navigator.pop(context, _cityController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                hintText: 'Enter a city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _search(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _search,
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
