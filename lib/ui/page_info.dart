import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';



class SettingsPage extends StatefulWidget {
  final User user;

  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}



class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin { 
      static final Uri _url = Uri.parse('https://w.egybest.cafe/');
      _launchUrl() async {
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              _getToolbar(context),
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
                              'Info',
                              style: TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold),
                            ),
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
            ],
          ),

          const Padding(padding: EdgeInsets.only(top: 50.0),),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              Card(
                color: Colors.white,
                elevation: 2.0,
                child: Column(
                  children:  <Widget>[
                    const ListTile(
                      leading: Icon(
                        FontAwesomeIcons.gears,
                        color: Colors.grey,
                      ),
                      title: Text("Version"),
                      trailing: Text("1.0.0"),
                    ),
                    const ListTile(
                      leading: Icon(
                        FontAwesomeIcons.mobile,
                        color: Colors.grey,
                      ),
                      title: Text("Platform"),
                      trailing: Text("Android & iOS"),
                    ),
                    
                    ListTile(
                      onTap: _launchUrl,
                      leading: const Icon(
                        FontAwesomeIcons.github,
                        color: Colors.black,
                      ),
                      title: const Text("GitHub"),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
