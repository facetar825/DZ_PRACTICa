import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Container(
            width: 260,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(0, 5),
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [


                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/my_photo.jpg",
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: 15),


                Text(
                  "67",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),


                Text(
                  "мС СВИН ",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 15),

                LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Colors.grey[300],
                  color: Colors.black,
                ),

                SizedBox(height: 15),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Icon(Icons.shuffle),

                    Icon(Icons.skip_previous),

                    Icon(
                      Icons.play_arrow,
                      size: 35,
                    ),

                    Icon(Icons.skip_next),

                    Icon(Icons.repeat),

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}