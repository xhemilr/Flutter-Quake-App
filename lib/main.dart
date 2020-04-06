import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:quake_app/Quake.dart';

void main() async{

  List<Quake> quakes = await getJsonItems();

  runApp(new MaterialApp(
    home: new Scaffold(
      appBar: new AppBar(
        title: new Text('Quake App'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: new Center(
        child: new ListView.builder(
            itemCount: quakes.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (BuildContext context, int position){
              return new ListTile(
                title: new Text(quakes[position].dateTime.toString(),
                style: new TextStyle(
                    fontSize: 22.0,
                    color: Colors.orange.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: new Text(quakes[position].location,
                  style: new TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic
                  ),
                ),
                leading: new CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.green,
                  child: new Text(quakes[position].magnitude.toString(),
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ),
                onTap: ()=> _showOnTapMessage(context, quakes[position].url),
              );
            }
        )
      ),
    ),
  ));
}

void _showOnTapMessage(BuildContext context, String message) async{
  var alert = new AlertDialog(
    title: new Text('Quake Details'),
    content: new FlatButton(onPressed: ()=> launch(message), child: new Text(message)),
    actions: [
      new FlatButton(onPressed: (){Navigator.pop(context);}, child: new Text('OK'))
    ],
  );

  showDialog(context: context, barrierDismissible: true, child: alert);
}

Future<List<Quake>> getJsonItems() async {
  String url = 'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&minmagnitude=5.7';
  http.Response response = await http.get(url);
  Map _data = json.decode(response.body);

  List features = _data['features'];
  List<Quake> quakes = new List();
  features.forEach((element) {
    Quake quake = new Quake(
        DateTime.fromMicrosecondsSinceEpoch(element['properties']['time']),
        element['properties']['place'],
        element['properties']['mag'],
        element['properties']['url']);
    quakes.add(quake);
  });

  return quakes;
}