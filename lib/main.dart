import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_1/models/item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = <Item>[];

  HomePage({super.key}) {
    items = [];
    // items.add(Item(title: "Academia", done: false));
    // items.add(Item(title: "Ciclismo", done: true));
    // items.add(Item(title: "Trabalho", done: false));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  Future loadItens() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  void addTask() {
    var text = newTaskCtrl.text;
    if (text.isNotEmpty) {
      setState(() {
        widget.items.add(
          Item(title: text, done: false),
        );
        newTaskCtrl.text = "";
        saveTask();
      });
    }
  }

  void editTask(Item item, bool? value) {
    setState(() {
      item.done = value;
      saveTask();
    });
  }

  void removeTask(int index) {
    setState(() {
      widget.items.removeAt(index);
      saveTask();
    });
  }

  saveTask() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    loadItens();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          decoration: InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Dismissible(
            // ignore: sort_child_properties_last
            child: CheckboxListTile(
              title: Text(item.title.toString()),
              value: item.done,
              onChanged: (value) {
                editTask(item, value);
              },
            ),
            key: Key(item.title.toString()),
            onDismissed: (direction) {
              removeTask(index);
            },
            background: Container(
              color: Colors.red,
              child: Text(
                "Excluir",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 0, 1, 2),
      ),
    );
  }
}
