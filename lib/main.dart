import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Map<String, dynamic>> comics = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedComics = prefs.getString('comics');
    if (storedComics != null) {
      setState(() {
        comics = List<Map<String, dynamic>>.from(json.decode(storedComics));
      });
    }
  }

  Future<void> _saveComics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('comics', json.encode(comics));
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        imageBase64 = base64Encode(bytes);
      });
    }
  }

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
                  decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author')),
              TextField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: 'Genre')),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _pickImage, child: const Text('Pick Image')),
              if (imageBase64 != null)
                Image.memory(base64Decode(imageBase64!), height: 100),
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
                    'image': imageBase64,
                  });
                  titleController.clear();
                  authorController.clear();
                  genreController.clear();
                  imageBase64 = null;
                });
                _saveComics();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
          ],
        );
      },
    );
  }

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
          const Text("Hold to Delete"),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: comics.length + 1,
              itemBuilder: (context, index) {
                if (index == comics.length) {
                  return GestureDetector(
                    onTap: _showAddComicDialog,
                    child: const Card(
                      color: Colors.blueAccent,
                      child: Center(
                        child: Icon(Icons.add, color: Colors.white, size: 50),
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
                              comics[index]['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(comics[index]['author'],
                                style: const TextStyle(fontSize: 12)),
                            Text(comics[index]['genre'],
                                style: const TextStyle(fontSize: 12)),
                            if (comics[index]['image'] != null)
                              Image.memory(
                                base64Decode(comics[index]['image']),
                                height: 100,
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
