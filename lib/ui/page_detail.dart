
// ignore_for_file: iterable_contains_unrelated_type

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoproject/model/element.dart';
import 'package:todoproject/utils/diamond_fab.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DetailPage extends StatefulWidget {
  final User user;
  final int i;
  final Map<String, List<ElementTask>> currentList;
  final String color;

  const DetailPage({Key? key, required this.user, required this.i, required this.currentList, required this.color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController itemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _getToolbar(context),
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(widget.user.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                      backgroundColor: currentColor,
                    ));
                  }
                  return Container(
                    child: getExpenseItems(snapshot),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: DiamondFab(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: currentColor!)),
                            labelText: "Item",
                            hintText: "Item",
                            contentPadding: const EdgeInsets.only(
                                left: 16.0,
                                top: 20.0,
                                right: 16.0,
                                bottom: 5.0)),
                        controller: itemController,
                        style: const TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  ButtonTheme(
                    //minWidth: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (itemController.text.isNotEmpty &&
                            !widget.currentList.values
                                .contains(itemController.text.toString())) {
                          FirebaseFirestore.instance
                              .collection(widget.user.uid)
                              .doc(
                                  widget.currentList.keys.elementAt(widget.i))
                              .update(
                                  {itemController.text.toString(): false});

                          itemController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(currentColor!),
                        
                      ),
                      child: const Text('Add',
                          style: TextStyle(
                          color: Color(0xffffffff),
                        )
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
        backgroundColor: currentColor!, foregroundColor: const Color.fromARGB(255, 255, 255, 255), tooltip: '',
        child: const Icon(Icons.add),
        
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ElementTask> listElement = [];
    int nbIsDone = 0;

    if (widget.user.uid.isNotEmpty) {
      snapshot.data!.docs.map<Column>((f) {
        Map d= (f.data() as Map);
        if (f.id == widget.currentList.keys.elementAt(widget.i)) {
          
          d.forEach((a, b) {
            if (b.runtimeType == bool) {

              return listElement.add(ElementTask(a, b));
            }
            
          });
        }
        

      return Column();
        
        
      }).toList();

      for (var i in listElement) {
        if (i.isDone) {
          nbIsDone++;
        }
      }
      var p= (listElement.length==0.0) ? 0.0 :nbIsDone/listElement.length;
      var p100= (p==0.0) ? 0 :(p*100).toStringAsFixed(0);

      return Column(
        
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 50.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          widget.currentList.keys.elementAt(widget.i),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35.0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Delete: ${widget.currentList.keys.elementAt(widget.i)}"),
                                content: const Text(
                                    "Are you sure you want to delete this list?", style: TextStyle(fontWeight: FontWeight.w400),),
                                actions: <Widget>[
                                  ButtonTheme(
                                    minWidth: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); 
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(currentColor!),
                                        
                                      ),
                                      child: const Text('NO',
                                        style: TextStyle(
                                        color: Color(0xffffffff),
                                       )
                                      ),
                                      ),
                                    ),
                                  ButtonTheme(
                                    //minWidth: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection(widget.user.uid)
                                            .doc(widget.currentList.keys
                                            .elementAt(widget.i))
                                            .delete();
                                        Navigator.pop(context);
                                        Navigator.of(context).pop();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(currentColor!)
                                      ),
                                      child: const Text('YES',
                                        style: TextStyle(
                                        color: Color(0xffffffff),
                                       )
                                      ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          FontAwesomeIcons.trash,
                          size: 25.0,
                          color: currentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 50.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "$nbIsDone of ${listElement.length} tasks",
                        style: const TextStyle(fontSize: 18.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 50,
                    animation: true,
                    lineHeight: 20.0,
                    animationDuration: 2500,
                    percent: p,
                    center: Text("$p100 %",
                      style: const TextStyle(
                        color: Color(0xffffffff),
                      )
                    ),
                    barRadius: const Radius.circular(16),
                    progressColor: currentColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(color: const Color(0xFFFCFCFC),child:
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 350,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: listElement.length,
                            itemBuilder: (BuildContext ctxt, int i) {
                              return Slidable(
                                // Specify a key if the Slidable is dismissible.
                                key: UniqueKey(),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.2,
                                 
                                  children: [
                                    // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
                                    SlidableAction(onPressed: (BuildContext) {
                                        FirebaseFirestore.instance
                                            .collection(widget.user.uid)
                                            .doc(widget.currentList.keys
                                            .elementAt(widget.i))
                                            .update({
                                          listElement.elementAt(i).name: "",
                                        });
                                      },
                                    flex: 3,
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    ),
                                  ],
                              ), 
                              child: GestureDetector(
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .collection(widget.user.uid)
                                        .doc(widget.currentList.keys
                                            .elementAt(widget.i))
                                        .update({
                                      listElement.elementAt(i).name:
                                          !listElement.elementAt(i).isDone
                                    });
                                  },
                                  child: Container(
                                    height: 50.0,
                                    color: listElement.elementAt(i).isDone
                                        ? const Color(0xFFF0F0F0)
                                        : const Color(0xFFFCFCFC),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 50.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            listElement.elementAt(i).isDone
                                                ? FontAwesomeIcons.squareCheck
                                                : FontAwesomeIcons.square,
                                            color: listElement
                                                    .elementAt(i)
                                                    .isDone
                                                ? currentColor
                                                : Colors.black,
                                            size: 20.0,
                                          ),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 30.0),
                                          ),
                                          Flexible(
                                            child: Text(
                                              listElement.elementAt(i).name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: listElement
                                                      .elementAt(i)
                                                      .isDone
                                                  ? TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: currentColor,
                                                      fontSize: 27.0,
                                                    )
                                                  : const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 27.0,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),),
                    ],
                  ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      );
      
    }
  }

  @override
  void initState() {
    super.initState();
    pickerColor = Color(int.parse(widget.color));
    currentColor = Color(int.parse(widget.color));
  }

  Color? pickerColor;
  Color? currentColor;

  ValueChanged<Color>? onColorChanged;

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Padding _getToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 12.0),
      child: SingleChildScrollView(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Image(
                width: 155.0,
                height: 60.0,
                fit: BoxFit.cover,
                image: AssetImage('assets/logo.png')
            ),
        ElevatedButton(
          onPressed: () {
            pickerColor = currentColor;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a color!'),
                  content: SingleChildScrollView(
                      child: BlockPicker(
                          pickerColor: pickerColor!,
                          onColorChanged: changeColor,
                      ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Got it'),
                      onPressed: () {

                        FirebaseFirestore.instance
                            .collection(widget.user.uid)
                            .doc(
                            widget.currentList.keys.elementAt(widget.i))
                            .update(
                            {"color": pickerColor!.value.toString()});

                        setState(
                                () => currentColor = pickerColor);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(currentColor!)
            ),
          child: const Icon(
              FontAwesomeIcons.palette,
              color: Color(0xffffffff),
              )
          ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.close,
            size: 40.0,
            color: currentColor,
          ),
        ),
      ]),
      ),
    );
  }
}