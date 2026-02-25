import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "이메일")),
            TextField(
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
