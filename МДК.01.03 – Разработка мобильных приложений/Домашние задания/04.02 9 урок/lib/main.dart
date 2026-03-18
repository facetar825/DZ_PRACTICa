import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LikePage(),
    );
  }
}

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  bool isLiked = false;
  int count = 0;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      count = isLiked ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: toggleLike,
              icon: Icon(
                Icons.favorite,
                color: isLiked ? Colors.red : Colors.grey,
                size: 40,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}