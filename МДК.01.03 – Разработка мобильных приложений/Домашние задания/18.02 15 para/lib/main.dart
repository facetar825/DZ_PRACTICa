import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Screen1(),
    );
  }
}


class Screen1 extends StatelessWidget {
  final TextEditingController controller =
  TextEditingController(text: "Вы правда это проверяйте ?");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Экран 1")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: controller,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Screen2(text: controller.text),
                  ),
                );
              },
              child: Text("Перейти на экран 2"),
            )
          ],
        ),
      ),
    );
  }
}


class Screen2 extends StatefulWidget {
  final String text;

  Screen2({required this.text});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {

  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  late Color bgColor;

  @override
  void initState() {
    super.initState();


    bgColor = colors[Random().nextInt(colors.length)];
  }

  void changeColor(Color newColor) {
    setState(() {
      bgColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: Text("Экран 2")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [


          Text(
            widget.text,
            style: TextStyle(
              fontSize: 24,
              color: bgColor,
            ),
          ),

          SizedBox(height: 40),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              GestureDetector(
                onTap: () => changeColor(Colors.red),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Красный"),
                ),
              ),

              GestureDetector(
                onTap: () => changeColor(Colors.green),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Зелёный"),
                ),
              ),

              GestureDetector(
                onTap: () => changeColor(Colors.blue),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Синий"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}