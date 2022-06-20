import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_crud/main.dart';
import 'package:intl/intl.dart';

import 'add_task.dart';

class HomeWidget extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(user.email!),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50)),
                  icon: const Icon(Icons.lock_open, size: 25),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class HomeListPage extends StatefulWidget {
  const HomeListPage({Key? key}) : super(key: key);

  @override
  _HomeListPage createState() => _HomeListPage();
}

class _HomeListPage extends State<HomeListPage> {
  final user = FirebaseAuth.instance.currentUser!;
  late CollectionReference tasks;

  @override
  void initState() {
    tasks = FirebaseFirestore.instance.collection("userData").doc(user.uid).collection('tasks');
    super.initState();
  }


  Future<void> deleteTask(id) {
    return tasks
        .doc(id)
        .delete()
        .then((value) => ("User Deleted"))
        .catchError((error) => print("Filed to delete"));
  }

  @override
  Widget build(BuildContext context) {
     final Stream<QuerySnapshot> listThings =
      FirebaseFirestore.instance.collection("userData").doc(user.uid).collection('tasks').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: listThings,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("Something went Wrong..");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final List dataList = [];
        snapshot.data!.docs.map((DocumentSnapshot document) {
          Map a = document.data() as Map<String, dynamic>;
          dataList.add(a);
          a['id'] = document.id;
        }).toList();
        print(dataList);
        return Scaffold(
            backgroundColor: Colors.white,
            drawer: Drawer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(user.email.toString(),style: const TextStyle(fontSize: 20),),
                  ),
                  IconButton(onPressed: (){
                      FirebaseAuth.instance.signOut();
                  }, icon: const Icon(Icons.logout)),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskPage(),
                  ),
                );
              },
              backgroundColor: Colors.lightBlue,
            ),
            body: CustomScrollView(
              shrinkWrap: true,
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                  elevation: 5.0,
                  floating: true,
                  snap: true,
                  collapsedHeight: 250,
                  pinned: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  expandedHeight: 250,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Row(
                            children: const [
                              Text(
                                "Your\n  Things",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 38,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(DateTime.now()),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                          color: Colors.blueAccent,
                          width: 4.0,
                        ),
                      )),
                      child: Image.asset(
                        'assets/images/hill.jpg',
                        color: const Color(0xff0d69ff).withOpacity(1),
                        colorBlendMode: BlendMode.softLight,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "INBOX",
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SingleChildScrollView(
                              child: dataList.isNotEmpty ? Column(
                                children: [
                                  ...dataList.map((e) => Dismissible(
                                        key: Key(e['id']),
                                        onDismissed: (direction) async {
                                          await deleteTask(e['id']);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      '${e['name']} deleted')));
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                              bottom: BorderSide(
                                                  width: 0.3,
                                                  color: Colors.black45),
                                            )),
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TaskPage(isUpdate: true,dataUpdate: e),
                                                  ),
                                                );
                                              },
                                              contentPadding: const EdgeInsets.all(0),
                                              leading: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff7c94b6),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              40.0)),
                                                  border: Border.all(
                                                    color: Colors.black26,
                                                    width: 0.0,
                                                  ),
                                                ),
                                                child: const CircleAvatar(
                                                  radius: 25,
                                                  child: Icon(
                                                      Icons.business,
                                                      color: Colors.blue,
                                                      size: 25),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                              title: Text(e["name"].toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0),
                                                child: Text(
                                                    e["description"].toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black26,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            )),
                                      )),
                                ],
                              ) : const Center(
                                child: Text("No Records Found.",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            ));
      },
    );
  }
}
