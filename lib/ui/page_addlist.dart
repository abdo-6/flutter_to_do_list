import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class NewTaskPage extends StatefulWidget {
  final User user;

  const NewTaskPage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  TextEditingController listNameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Color pickerColor = const Color(0xff6633ff);
  Color currentColor = const Color(0xff6633ff);

  ValueChanged<Color>? onColorChanged;

  bool _saving = false;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  Future<void> initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      connectionStatus = 'Failed to get connectivity.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  void addToFirebase() async {
    setState(() {
      _saving = true;
    });

    if (kDebugMode) {
      print(_connectionStatus);
    }

    if(_connectionStatus == "ConnectivityResult.none"){
      showInSnackBar("No internet connection currently available");
      setState(() {
        _saving = false;
      });
    } else {

      bool isExist = false;

      QuerySnapshot query =
      await FirebaseFirestore.instance.collection(widget.user.uid).get();

      for (var doc in query.docs) {
        if (listNameController.text.toString() == doc.id) {
          isExist = true;
        }
      }

      if (isExist == false && listNameController.text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(widget.user.uid)
            .doc(listNameController.text.toString().trim())
            .set({
          "color": currentColor.value.toString(),
          "date": DateTime.now().millisecondsSinceEpoch
        });

        listNameController.clear();

        pickerColor;
        currentColor = const Color(0xff6633ff);

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
      if (isExist == true) {
        showInSnackBar("This list already exists");
        setState(() {
          _saving = false;
        });
      }
      if (listNameController.text.isEmpty) {
        showInSnackBar("Please enter a name");
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: Stack(
            children: <Widget>[
              _getToolbar(context),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
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
                                  'New',
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'List',
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
                    padding:
                        const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.teal)),
                              labelText: "List name",
                              contentPadding: EdgeInsets.only(
                                  left: 16.0,
                                  top: 20.0,
                                  right: 16.0,
                                  bottom: 5.0)),
                          controller: listNameController,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 22.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 20,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                        ),
                        ButtonTheme(
                          minWidth: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              pickerColor = currentColor;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Pick a color!'),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                          pickerColor: pickerColor,
                                          onColorChanged: changeColor,
                                        ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Got it'),
                                        onPressed: () {
                                          setState(() =>
                                              currentColor = pickerColor);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(currentColor),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.palette,
                              color: Color(0xffffffff),
                              ),
                          ),
                        ),
                      ],
                    ),
                    
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Column(
                      children: <Widget>[
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue
                          ),
                            ),
                          onPressed: addToFirebase,
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
          ),
    );
  }

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _connectionStatus = result.toString();
          });
        });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value, textAlign: TextAlign.center),
      backgroundColor: currentColor,
      duration: const Duration(seconds: 3),
    ));
  }

  Container _getToolbar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, top: 40.0),
      child: const BackButton(color: Colors.black),
    );
  }
}
