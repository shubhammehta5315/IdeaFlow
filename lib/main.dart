import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
        accentColor: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'IDEAFLOW',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.indigo.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AutocompleteWidget(),
        ),
      ),
    );
  }
}

class AutocompleteWidget extends StatefulWidget {
  @override
  _AutocompleteWidgetState createState() => _AutocompleteWidgetState();
}

class _AutocompleteWidgetState extends State<AutocompleteWidget> {
  List<Idea> items = [];
  TextEditingController _controller = TextEditingController();
  bool isLinkingMode = false;
  String selectedLinkingEntity = '';

  void addItemToList(String title, String description) {
    if (title.isNotEmpty) {
      setState(() {
        if (selectedLinkingEntity.isNotEmpty) {
          final linkingText = _controller.text;
          final suggestionWithBrackets = '<$selectedLinkingEntity>';
          final updatedText = linkingText.replaceFirst(
              RegExp('<[^>]*>'), suggestionWithBrackets);
          _controller.text = updatedText;
          selectedLinkingEntity = '';
        }
        items.insert(0, Idea(title: title, description: description));
        _controller.clear();
      });
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save List'),
          content: Text('Do you want to save the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveList();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveList() {
    print('List items:');
    for (Idea idea in items) {
      print('Title: ${idea.title}, Description: ${idea.description}');
    }
  }

  void _clearList() {
    setState(() {
      items.clear();
    });
  }

  void _deleteList() {
    setState(() {
      items.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'List deleted!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
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
                    onChanged: (text) {
                      setState(() {
                        isLinkingMode = text.contains('<') && text.contains('>');
                      });
                    },
                    onSubmitted: (text) {
                      if (isLinkingMode) {
                        final linkingText = _controller.text;
                        final suggestionWithBrackets = '<$selectedLinkingEntity>';
                        final updatedText = linkingText.replaceFirst(RegExp('<[^>]*>'), suggestionWithBrackets);
                        _controller.text = updatedText;
                        selectedLinkingEntity = '';
                      }
                      addItemToList(text, '');
                    },
                  ),
                  suggestionsCallback: (pattern) async {
                    return items
                        .where((item) => item.title.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLinkingMode ? Colors.blue : null),
                      ),
                      onTap: () {
                        setState(() {
                          if (isLinkingMode) {
                            selectedLinkingEntity = suggestion.title;
                          } else {
                            _controller.text = suggestion.title;
                          }
                        });
                        _controller.selection =
                            TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
                      },
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      if (isLinkingMode) {
                        selectedLinkingEntity = suggestion.title;
                      } else {
                        _controller.text = suggestion.title;
                      }
                    });
                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  },
                ),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  shape: CircleBorder(),
                ),
                onPressed: () {
                  if (isLinkingMode) {
                    final linkingText = _controller.text;
                    final suggestionWithBrackets = '<$selectedLinkingEntity>';
                    final updatedText = linkingText.replaceFirst(RegExp('<[^>]*>'), suggestionWithBrackets);
                    _controller.text = updatedText;
                    selectedLinkingEntity = '';
                  }
                  addItemToList(_controller.text, '');
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final isCurrentLinkingEntity = items[index].title == selectedLinkingEntity;
              return ListTile(
                key: ValueKey(items[index].title),
                title: Text(
                  items[index].title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentLinkingEntity ? Colors.blue : null,
                  ),
                ),
                subtitle: Text(items[index].description),
                onTap: () {
                  setState(() {
                    if (selectedLinkingEntity.isNotEmpty) {
                      final linkingText = _controller.text;
                      final suggestionWithBrackets = '<$selectedLinkingEntity>';
                      final updatedText = linkingText.replaceFirst(RegExp('<[^>]*>'), suggestionWithBrackets);
                      _controller.text = updatedText;
                      selectedLinkingEntity = '';
                    }
                  });
                },
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              setState(() {
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
              });
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
            _deleteList();
          },
          child: const Text('Delete List'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Idea {
  final String title;
  final String description;

  Idea({required this.title, required this.description});
}
