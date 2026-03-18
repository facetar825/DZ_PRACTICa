import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
    );
  }
}


class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String name = "Я Кинул камень а вы ";
  String status = "Только честно";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Профиль пользователя")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(Icons.person, size: 60),

            SizedBox(height: 10),

            Text("Имя: $name"),
            Text("Статус: $status"),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {


                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      name: name,
                      status: status,
                    ),
                  ),
                );


                if (result != null) {
                  setState(() {
                    name = result["name"];
                    status = result["status"];
                  });
                }
              },
              child: Text("Редактировать"),
            )
          ],
        ),
      ),
    );
  }
}


class EditProfileScreen extends StatelessWidget {

  final TextEditingController nameController;
  final TextEditingController statusController;

  EditProfileScreen({required String name, required String status})
      : nameController = TextEditingController(text: name),
        statusController = TextEditingController(text: status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Редактировать профиль")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Имя"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: statusController,
              decoration: InputDecoration(labelText: "Статус"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {

                final data = {
                  "name": nameController.text,
                  "status": statusController.text,
                };


                Navigator.pop(context, data);
              },
              child: Text("Сохранить"),
            )
          ],
        ),
      ),
    );
  }
}