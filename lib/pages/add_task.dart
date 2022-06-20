import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key, this.isUpdate = false, this.dataUpdate})
      : super(key: key);

  final isUpdate;
  final dataUpdate;

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _formKey = GlobalKey<FormState>();

  var name = "";
  var desc = "";
  var date = "";
  var id = "";
  final nameController = TextEditingController();
  final desController = TextEditingController();
  final dateController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  late CollectionReference tasks;
  @override
  void initState() {
    if (widget.isUpdate) {
      nameController.text = widget.dataUpdate["name"].toString();
      desController.text = widget.dataUpdate["description"].toString();
      dateController.text = widget.dataUpdate["date"].toString();
      id = widget.dataUpdate["id"];
    }
    tasks = FirebaseFirestore.instance.collection("userData").doc(user.uid).collection('tasks');

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    desController.dispose();
    dateController.dispose();
    super.dispose();
  }

  clearText() {
    nameController.clear();
    desController.clear();
    dateController.clear();
  }

  Future<void> addTask({isUpdate = false}) {
    if (isUpdate) {
      return tasks
          .doc(id)
          .update({
            "name": nameController.text,
            "description": desController.text,
            "date": dateController.text
          })
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    } else {
      return tasks
          .add({
            "name": nameController.text,
            "description": desController.text,
            "date": dateController.text
          })
          .then((value) => print("Added task"))
          .catchError((onError) => print("catch added error"));
    }
  }

  Future _selectDate() async {
    final datepic = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        initialDate: DateTime.now(),
        lastDate: DateTime(2100));
    setState(() {
      if (datepic != null) {
        dateController.text = DateFormat("dd MMM yyyy").format(datepic);
        date = dateController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 91, 247),
      appBar: AppBar(
        title: Center(
            child: Text(
          widget.isUpdate ? "Update Thing" : "Add new thing",
          style: const TextStyle(color: Colors.white),
        )),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.tune),
          )
        ],
        backgroundColor: const Color.fromARGB(255, 63, 91, 247),
        elevation: 0,
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: const Color.fromARGB(255, 91, 172, 238), size: 30),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: ListView(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 27,
                child: CircleAvatar(
                  radius: 25,
                  child: Icon(
                      Icons.business,
                      color: Colors.blue,
                      size: 25),
                  backgroundColor: Color.fromARGB(255, 63, 91, 247),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  style: const TextStyle(
                      color: Colors.white, decorationColor: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Name';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  style: const TextStyle(
                      color: Colors.white, decorationColor: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description ',
                    labelStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: desController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Description';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  style: const TextStyle(
                      color: Colors.white, decorationColor: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Date ',
                    labelStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: dateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Select Date';
                    }
                    return null;
                  },
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await _selectDate();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, otherwise false.
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        name = nameController.text;
                        desc = desController.text;
                        date = dateController.text;
                        addTask(isUpdate: widget.isUpdate);
                        clearText();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(widget.isUpdate
                                ? "Thing Updated"
                                : "New Thing Added")));
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 91, 172, 238)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      widget.isUpdate ? "UPDATE THING" : 'ADD YOUR THING',
                      style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
