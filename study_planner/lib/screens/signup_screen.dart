import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "이메일")),
            TextField(
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: "비밀번호 확인"),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
