import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/utils.dart' as util;

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator
        .of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new ChangeCity();
    }));
    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'].toString();
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
    double temp = data['main']['temp'];
    print(temp.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Weather"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () {
                _goToNextScreen(context);
              }),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              "images/thunder.jpg",
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          new Container(
            child: new Text(
              '${_cityEntered == null ? util.defaultCity : _cityEntered}',
              style: cityStyle(),
            ),
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),
          //Container that will contain weather data
          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 350.0, 0.0, 0.0),
            alignment: Alignment.center,
            child: updateTempWidget(_cityEntered),
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appId="
        "$appId&units=imperial";

    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          //where we process our json data
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Container(
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      content['main']['temp'].toString() + " F",
                      style: temperatureStyle(),
                    ),
                    subtitle: new ListTile(
                      title: new Text(
                        "Humidity: ${content['main']['humidity'].toString()}%\n"
                            "Recorded High:  ${content['main']['temp_max']
                            .toString()} F\n"
                            "Recorded Low:  ${content['main']['temp_min']
                            .toString()} F",
                        style: new TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.redAccent,
        title: new Text('Change City'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/clear_night.jpg',
              height: 1200.0,
              width: 490.0,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              new ListTile(
                title: new FlatButton(
                    onPressed: () {
                      Navigator
                          .pop(context, {'enter': _cityFieldController.text});
                    },
                    textColor: Colors.white70,
                    color: Colors.redAccent,
                    child: new Text("Check Weather")),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle temperatureStyle() {
  return new TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 49.9,
  );
}
