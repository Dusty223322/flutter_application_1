import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Comic Library')),
        body: const ComicLibrary(),
      ),
    );
  }
}

class ComicLibrary extends StatefulWidget {
  const ComicLibrary({super.key});

  @override
  State<ComicLibrary> createState() => _ComicLibraryState();
}

class _ComicLibraryState extends State<ComicLibrary> {
  // In-memory data, would be loaded from a JSON file in a real app
  List<Map<String, String>> comics = [];

  // Controllers for text input
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  // Popup to add comic
  void _showAddComicDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Comic'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  comics.add({
                    'title': titleController.text,
                    'author': authorController.text,
                    'genre': genreController.text
                  });
                  titleController.clear();
                  authorController.clear();
                  genreController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Long press to delete comic
  void _deleteComic(int index) {
    setState(() {
      comics.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: comics.length + 1, // extra item for 'add' button
              itemBuilder: (context, index) {
                if (index == comics.length) {
                  return GestureDetector(
                    onTap: _showAddComicDialog,
                    child: Card(
                      color: Colors.blueAccent,
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onLongPress: () => _deleteComic(index),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              comics[index]['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              comics[index]['author']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              comics[index]['genre']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
