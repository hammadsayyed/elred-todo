import 'package:flutter/material.dart';
import 'package:flutter_firebase_crud/pages/login_page.dart';

import 'sign_up_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggle() => setState(() {
        isLogin = !isLogin;
      });

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedSignUp: toggle)
      : SignUpWidget(onClickedSignUp: toggle);
}
