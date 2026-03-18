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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLiked = false;
  int likeCount = 0;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? 1 : 0;
    });
  }


  Color backgroundColor = Colors.white;

  void changeBackground(Color color) {
    setState(() {
      backgroundColor = color;
    });
  }


  final List<String> _statuses = [
    'играю в доту',
    'не играю доту',
    'в запое ',
    'Не в сети'
  ];

  final List<Color> _statusColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.grey
  ];

  int _currentStatusIndex = 0;

  void nextStatus() {
    setState(() {
      _currentStatusIndex =
          (_currentStatusIndex + 1) % _statuses.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text('Практика '),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GFIconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    Icons.favorite,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
                Text(
                  '$likeCount',
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),

            const SizedBox(height: 30),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GFButton(
                  text: 'Синий',
                  color: Colors.blue,
                  onPressed: () => changeBackground(Colors.blue),
                ),
                const SizedBox(width: 10),
                GFButton(
                  text: 'Зелёный',
                  color: Colors.green,
                  onPressed: () => changeBackground(Colors.green),
                ),
                const SizedBox(width: 10),
                GFButton(
                  text: 'Жёлтый',
                  color: Colors.orange,
                  onPressed: () => changeBackground(Colors.orange),
                ),
              ],
            ),

            const SizedBox(height: 40),


            GFCard(
              color: _statusColors[_currentStatusIndex],
              elevation: 6,
              margin: const EdgeInsets.all(16),
              content: Column(
                children: [
                  const GFAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Cаня',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  GFListTile(
                    titleText: 'Статус',
                    subTitleText: _statuses[_currentStatusIndex],
                    icon: const Icon(Icons.info),
                  ),

                  const SizedBox(height: 10),

                  GFButton(
                    text: 'Сменить статус',
                    onPressed: nextStatus,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}