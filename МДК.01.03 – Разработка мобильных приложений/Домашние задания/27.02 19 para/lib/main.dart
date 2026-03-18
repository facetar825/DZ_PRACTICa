import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int currentIndex = 0;

  // контроллер для поиска
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    List<Widget> screens = [

      // --- Главная ---
      Center(child: Text("Главная")),

      // --- Поиск ---
      Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Введите запрос",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {

                // показываем диалог
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Ваш запрос"),
                    content: Text(searchController.text),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("OK"),
                      )
                    ],
                  ),
                );
              },
              child: Text("Поиск"),
            )
          ],
        ),
      ),

      // --- Профиль ---
      Center(child: Text("Профиль")),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Приложение")),

        body: screens[currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Главная",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Поиск",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Профиль",
            ),
          ],
        ),
      ),
    );
  }
}