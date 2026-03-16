import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal[900],
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Container(
                  width: 300,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            ' ПРОФИЛЬ ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),


                Container(
                  width: 300,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal[100],
                        backgroundImage: AssetImage('assets/profile.jpg'),
                        child: Icon(Icons.person, size: 50, color: Colors.teal[800]),
                      ),
                      SizedBox(height: 15),


                      Text(
                        'Мингазов Алексанжр', // ⬅️
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 5),


                      Text(
                        'Почти сам сделал ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal[600],
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 20),


                      Divider(
                        color: Colors.teal[200],
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      SizedBox(height: 10),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContactIcon(Icons.phone, Colors.teal[700], 'Телефон'),
                          _buildContactIcon(Icons.email, Colors.teal[700], 'Email'),
                          _buildContactIcon(Icons.link, Colors.teal[700], 'Сайт'),
                          _buildContactIcon(Icons.telegram, Colors.teal[700], 'Telegram'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildContactIcon(IconData icon, Color? color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}