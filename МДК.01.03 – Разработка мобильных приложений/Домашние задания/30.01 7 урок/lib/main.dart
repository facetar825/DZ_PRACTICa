import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileCard(),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.black26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GFAvatar(
                size: 80,
                backgroundColor: Colors.blueGrey,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Сана',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'Кто я ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              GFRating(
                value: 4,
                itemCount: 5,
                size: GFSize.SMALL,
                color: Colors.amber,
                borderColor: Colors.amber,
                allowHalfRating: true,
                onChanged: (value) {},
              ),

              const SizedBox(height: 24),

              const GFListTile(
                titleText: 'Email',
                subTitleText: 'Facetar825@gmail.com',
                icon: Icon(Icons.email),
              ),

              const GFListTile(
                titleText: 'Телефон',
                subTitleText: '+7 923 223 42 43',
                icon: Icon(Icons.phone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
