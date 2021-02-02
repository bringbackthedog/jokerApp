import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Constants
const String jokeAPIEndPoint =
    'https://official-joke-api.appspot.com/random_joke';

void main() {
  runApp(JokerApp());
}

class JokerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<Joke> futureJoke;

  @override
  void initState() {
    futureJoke = Joke.fetchJoke();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Joker App: Get it? "),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: height,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: futureJoke,
              builder: (context, AsyncSnapshot<Joke> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Text(
                          snapshot.data.setup,
                          style: TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PunchLine(snapshot: snapshot),
                      // Get Another joke
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            futureJoke = Joke.fetchJoke();
                          });
                        },
                        child: Text('Get another joke'),
                      ),
                    ],
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  throw "Failed to fetch a joke...";
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PunchLine extends StatefulWidget {
  final AsyncSnapshot<Joke> snapshot;
  PunchLine({this.snapshot});
  @override
  _PunchLineState createState() => _PunchLineState();
}

class _PunchLineState extends State<PunchLine> {
  bool showingPunchLine = false;
  toggleShowingPunchLine() => setState(
        () => showingPunchLine = !showingPunchLine,
      );

  @override
  void initState() {
    showingPunchLine = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PunchLine
        Visibility(
          visible: showingPunchLine,
          child: Container(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              widget.snapshot.data.punchLine,
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        //Show punchline
        Visibility(
          visible: !showingPunchLine,
          child: ElevatedButton(
            onPressed: () => toggleShowingPunchLine(),
            child: Text('Get punch line'),
          ),
        ),
      ],
    );
  }
}

// Joke Model
class Joke {
  String setup;
  String punchLine;

  Joke({this.setup, this.punchLine});

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      setup: json['setup'],
      punchLine: json['punchline'],
    );
  }

  static Future<Joke> fetchJoke() async {
    final response = await http.get(jokeAPIEndPoint);

    if (response.statusCode == 200) {
      return Joke.fromJson(jsonDecode(response.body));
    } else {
      throw "Failed to get a joke...";
    }
  }
}
