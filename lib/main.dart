import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Comic Library')),
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
  List<Map<String, dynamic>> comics = [];

  // Controllers for text input
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  // Picked image path
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/comics.json');

    if (file.existsSync()) {
      final String content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      setState(() {
        comics = jsonData
            .map((comic) => {
                  'title': comic['title'],
                  'author': comic['author'],
                  'genre': comic['genre'],
                  'image': comic['image'], // Image path
                })
            .toList();
      });
    }
  }

  Future<void> _saveComics() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/comics.json');

    final String jsonContent = json.encode(comics);
    await file.writeAsString(jsonContent);
  }

  void _showAddComicDialog() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imagePath = pickedImage.path;
      });
    }

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
              imagePath != null
                  ? Image.file(File(imagePath!))
                  : Container(), // Display the image if picked
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  comics.add({
                    'title': titleController.text,
                    'author': authorController.text,
                    'genre': genreController.text,
                    'image': imagePath, // Save image path
                  });
                  titleController.clear();
                  authorController.clear();
                  genreController.clear();
                  imagePath = null; // Reset image path after adding comic
                });
                _saveComics();
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
    _saveComics();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hold to Delete"),
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
                            comics[index]['image'] != null
                                ? Image.file(
                                    File(comics[index]['image']),
                                    height: 100,
                                  )
                                : Container(),
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
