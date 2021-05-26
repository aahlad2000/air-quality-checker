import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() => runApp(new MaterialApp(
  home: new HomePage(),
));


class HomePage extends StatefulWidget{
  @override
  HomePageState createState() => new HomePageState();
}

class Data {
  double temperature;
  int humidity;
  int dust;
  int light;
  int mq135;
  int mq9;
  int mq8;

  Data({this.temperature, this.humidity, this.dust, this.light, this.mq135, this.mq9, this.mq8});

  Data.fromJson(Map<String, dynamic> json) {
    temperature = json['temperature'];
    humidity = json['humidity'];
    dust = json['dust'];
    light = json['light'];
    mq135 = json['mq135'];
    mq9 = json['mq9'];
    mq8 = json['mq8'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temperature'] = this.temperature;
    data['humidity'] = this.humidity;
    data['dust'] = this.dust;
    data['light'] = this.light;
    data['mq135'] = this.mq135;
    data['mq9'] = this.mq9;
    data['mq8'] = this.mq8;
    return data;
  }
}

class NewScreen extends StatelessWidget {
  String payload;

  NewScreen({
    @required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALERT!'),
      ),
      body: new Text("The temperature and humdity are too high."
          " You might want to switch on the Air Conditioner and Air purifier.")
    );
  }
}


class HomePageState extends State<HomePage>{
  final String url = "https://node-red-nvnuz-2021-05-23.mybluemix.net/AQ";
  Data data;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState(){
    super.initState();
    this.getJsonData();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOs);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);

  }

  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  showNotification(header,body) async {
    var android = AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.High, importance: Importance.Max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, header, body, platform,
        payload: body);
  }

  Future<String> getJsonData() async {
    setState((){
      getData();
    });
    return "Success";
  }

  void getData() async {
    var response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"});
    Map<String, dynamic> convertDataToJson = jsonDecode(response.body);
    data = Data.fromJson(convertDataToJson);
    print("Data: " + data.toString());
  }
   @override
    Widget build(BuildContext context) {
     return new Scaffold(
       appBar: new AppBar(
         title: Center(child: new Text("AQ Checker Data")),
         backgroundColor: Colors.deepOrange,
        ),
         body: new ListView.builder(
          itemCount: data != null ? 1 : 0,
          itemBuilder: (BuildContext context,int index){
          return new Container(
            child : new Center(
              child : new Column(
                crossAxisAlignment : CrossAxisAlignment.stretch,
                children : <Widget>[
                  new Card(
                    child: new Container(
                      child: new Text("Temperature: " + data.temperature.toString()
                      ),
                      padding : EdgeInsets.all(20.0)
                    ),
                  ),
                  new Card(
                    child: new Container(
                        child: new Text(
                            "Humidity: " + data.humidity.toString()
                        ),
                        padding : EdgeInsets.all(20.0)
                    ),
                  ),
                  new Card(
                    child: new Container(
                        child: new Text("Dust: " + data.dust.toString()
                        ),
                        padding : EdgeInsets.all(20.0)
                    ),
                  ),
                  new Card(
                    child: new Container(
                        child: new Text("Light: " + data.light.toString()
                        ),
                        padding : EdgeInsets.all(20.0)
                    ),
                  ),
                  new Card(
                    child: new Container(
                        child: new Text("MQ135: " + data.mq135.toString()
                        ),
                        padding : EdgeInsets.all(20.0)
                    ),
                  ),

                  new Card(
                    child: new Container(
                        child: new Text("MQ9: " + data.mq9.toString()
                        ),
                        padding : EdgeInsets.all(20.0)
                    ),
                  ),
                  new Card(
                    child: new Container(
                        child: new Text("MQ8: " + data.mq8.toString()
                        ),
                        padding : EdgeInsets.all(20.0)
                    ),
                  )
                ],
              )
            )
          );
          }
      ),

       floatingActionButton: Stack(
         children: [ Padding(
           padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
           child: Align(
               alignment: Alignment.bottomLeft,
             child: FloatingActionButton(
               onPressed: () {
                 setState((){
                   getData();

                 });
                 if(data.temperature>34 || data.humidity>30){
                   showNotification('AQ Checker notification!','The temperature and humidity are too high. Please Switch on the AC.');
                 }

                 // Add your onPressed code here!
               },
               child: const Icon(Icons.refresh),
               backgroundColor: Colors.red,
             ),

           )
         ),
           Padding(
               padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
               child: Align(
                 alignment: Alignment.bottomRight,
                 child: FloatingActionButton(
                   onPressed: () {
                     setState((){
                       getData();
                     });
                     // Add your onPressed code here!
                   },
                   child: const Icon(Icons.info_outline),
                   backgroundColor: Colors.red,
                 ),

               )
           )

         ],
       ),

    );

  }
}
