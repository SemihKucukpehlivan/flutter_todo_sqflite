import 'package:flutter/material.dart';
import '../model/note_model.dart';
import '../services/database_helper.dart';
import '../widgets/note_widgets.dart';
import 'note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteScreen(),
            ),
          );
          setState(() {});
        },
      ),
      body: FutureBuilder<List<Note>?>(
        future: DatabaseHelper.getAllNote(),
        builder: (context, AsyncSnapshot<List<Note>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemBuilder: (context, index) => NoteWidget(
                  note: snapshot.data![index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteScreen(
                          note: snapshot.data![index],
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  onLongPress: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                              "Are you sure want to delete this note?"),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                await DatabaseHelper.deleteNote(
                                    snapshot.data![index]);
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: const Text("Yes"),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("No"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                itemCount: snapshot.data!.length,
              );
            }
            return const Center(
              child: Text("No notes yet!"),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
