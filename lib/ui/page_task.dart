
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoproject/model/element.dart';
import 'package:todoproject/ui/page_detail.dart';

import 'page_addlist.dart';

class TaskPage extends StatefulWidget {
  final User user;

  const TaskPage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  int index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _getToolbar(context),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              'Task',
                              style: TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lists',
                              style: TextStyle(
                                  fontSize: 28.0, color: Colors.grey),
                            )
                          ],
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: const BorderRadius.all(Radius.circular(7.0))),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTaskPressed,
                        iconSize: 30.0,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text('Add List',
                          style: TextStyle(color: Colors.black45)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              height: 360.0,
              padding: const EdgeInsets.only(bottom: 25.0),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.user.uid)
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        )
                        );
                      }
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                        scrollDirection: Axis.horizontal,
                        children: getExpenseItems(snapshot),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ElementTask> listElement = [], listElement2;
    late Map<String, List<ElementTask>> userMap = {};

    List<String> cardColor = [];

    if (widget.user.uid.isNotEmpty) {
      cardColor.clear();

      snapshot.data!.docs.map<List>((f) {
        late String color;
        late Map d= (f.data() as Map);
         d.forEach((a, b) {
          if (b.runtimeType == bool) {
            listElement.add(ElementTask(a, b));
          }
          if (b.runtimeType == String && a == "color") {
            color = b;
          }
        });
        listElement2 = List<ElementTask>.from(listElement);
        for (int i = 0; i < listElement2.length; i++) {
          if (listElement2.elementAt(i).isDone == false) {
            userMap[f.id] = listElement2;
            cardColor.add(color);
            break;
          }
        }
        if (listElement2.isEmpty) {
          userMap[f.id] = listElement2;
          cardColor.add(color);
        }
        listElement.clear();
        
        return listElement ;
      }).toList();

      return List.generate(userMap.length, (int index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => DetailPage(
                      user: widget.user,
                      i: index,
                      currentList: userMap,
                      color: cardColor.elementAt(index),
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        ScaleTransition(
                          scale: Tween<double>(
                            begin: 1.5,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: const Interval(
                                0.50,
                                1.00,
                                curve: Curves.linear,
                              ),
                            ),
                          ),
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: const Interval(
                                  0.00,
                                  0.50,
                                  curve: Curves.linear,
                                ),
                              ),
                            ),
                            child: child,
                          ),
                        ),
              ),
            );
          },
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            color: Color(int.parse(cardColor.elementAt(index))),
            child: SizedBox(
              width: 220.0,
              //height: 100.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                    child: Text(
                      userMap.keys.elementAt(index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(left: 50.0),
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30.0, left: 15.0, right: 5.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 220.0,
                          child: ListView.builder(
                              //physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  userMap.values.elementAt(index).length,
                              itemBuilder: (BuildContext ctxt, int i) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      userMap.values
                                              .elementAt(index)
                                              .elementAt(i)
                                              .isDone
                                          ? FontAwesomeIcons.circleCheck
                                          : FontAwesomeIcons.circle,
                                      color: userMap.values
                                              .elementAt(index)
                                              .elementAt(i)
                                              .isDone
                                          ? Colors.white70
                                          : Colors.white,
                                      size: 14.0,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userMap.values
                                            .elementAt(index)
                                            .elementAt(i)
                                            .name,
                                        style: userMap.values
                                                .elementAt(index)
                                                .elementAt(i)
                                                .isDone
                                            ? const TextStyle(
                                                decoration: TextDecoration
                                                    .lineThrough,
                                                color: Colors.white70,
                                                fontSize: 17.0,
                                              )
                                            : const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.0,
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _addTaskPressed() async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NewTaskPage(
              user: widget.user,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            ScaleTransition(
              scale: Tween<double>(
                begin: 1.5,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(
                    0.50,
                    1.00,
                    curve: Curves.linear,
                  ),
                ),
              ),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(
                      0.00,
                      0.50,
                      curve: Curves.linear,
                    ),
                  ),
                ),
                child: child,
              ),
            ),
      ),
    );
    //Navigator.of(context).pushNamed('/new');
  }

  Padding _getToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child:
      Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Image(
            width: 170.0,
            height: 70.0,
            fit: BoxFit.cover,
            image: AssetImage('assets/logo.png')
        ),
      ]),
    );
  }
}
