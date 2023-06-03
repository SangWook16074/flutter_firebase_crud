import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/firebase_const.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TextEditingController _todo;

  void createTodo() {
    firebaseFirestore.collection('todo').add({
      'todo': _todo.value.text.trim(),
      'isDone': false,
      'time': Timestamp.now(),
    });

    _todo.clear();
  }

  void updateTodo(String id) {
    firebaseFirestore.collection('todo').doc(id).update({
      'isDone': true,
    });
  }

  void deleteTodo(String id) {
    firebaseFirestore.collection('todo').doc(id).delete();
  }

  @override
  void initState() {
    super.initState();
    _todo = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _todo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Todo App',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            _header(),
            _todos(),
          ],
        ));
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.66,
            child: TextField(
              controller: _todo,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: createTodo, child: const Icon(Icons.send)),
        )
      ],
    );
  }

  Widget _todos() {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseFirestore
          .collection('todo')
          .orderBy(
            'time',
          )
          .snapshots(),
      builder: (context, snapshot) =>
          (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index];
                      final todo = data['todo'];
                      final isDone = data['isDone'];
                      final time = data['time'].toString();

                      return ListTile(
                        title: Text(todo),
                        subtitle: Text(time),
                        leading: (isDone)
                            ? GestureDetector(
                                onTap: () {
                                  deleteTodo(data.id);
                                },
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  updateTodo(data.id);
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                      );
                    },
                  ),
                ),
    );
  }
}
