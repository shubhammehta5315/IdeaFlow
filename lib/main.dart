import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'IDEAFLOW',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
        ),
        body: AutocompleteWidget(),
      ),
    );
  }
}

class AutocompleteWidget extends StatefulWidget {
  @override
  _AutocompleteWidgetState createState() => _AutocompleteWidgetState();
}

class _AutocompleteWidgetState extends State<AutocompleteWidget> {
  List<String> items = [];
  TextEditingController _controller = TextEditingController();

  void addItemToList(String item) {
    if (item.isNotEmpty) {
      setState(() {
        items.add(item);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter New Ideas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: addItemToList,
            ),
            suggestionsCallback: (pattern) async {
              return items
                  .where((item) =>
                  item.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(
                  suggestion,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _showDeleteOption(context, suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _controller.text = suggestion;
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(items[index]),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    items.removeAt(index);
                  });
                },
                child: ListTile(
                  title: Text(
                    items[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showDeleteOption(context, items[index]),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            // Save the list or perform any other action here.
            _showSaveDialog();
          },
          child: const Text('Save List'),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).accentColor,
            onPrimary: Colors.white,
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            // Clear the list.
            _clearList();
          },
          child: const Text('Clear List'),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            // Delete the list.
            _deleteList();
          },
          child: const Text('Delete List'),
        ),
      ],
    );
  }

  // Rest of the code remains unchanged...
  // ...

  // Show a dialog to confirm saving the list.
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save List'),
          content: const Text('Do you want to save the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform the save action or navigate to another screen to save the list.
                _saveList();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Save the list to a persistent storage or perform any other required action.
  void _saveList() {
    // Here, we'll just print the list to the console.
    print('List items:');
    for (String item in items) {
      print(item);
    }
  }

  // Clear the list.
  void _clearList() {
    setState(() {
      items.clear();
    });
  }

  // Delete the list.
  void _deleteList() {
    setState(() {
      items.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'List deleted!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show the delete option for the selected item.
  void _showDeleteOption(BuildContext context, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Do you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(item);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete the selected item from the list.
  void _deleteItem(String item) {
    setState(() {
      items.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item deleted!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
