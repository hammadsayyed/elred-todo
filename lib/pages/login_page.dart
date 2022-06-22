import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_crud/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginWidgetPageState createState() => _LoginWidgetPageState();
}

class _LoginWidgetPageState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future signIn() async {
    final isValid = loginFormKey.currentState!.validate();
    if(!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print("login catch");
      print(e);
      final sanckBar = SnackBar(
        content:
            Text(e.message.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(sanckBar);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Sign in',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lato(textStyle:const TextStyle(color: Colors.blue, fontSize: 50, fontWeight: FontWeight.w400))),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) {
                    // Check if this field is empty
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) {
                    // Check if this field is empty
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: signIn,
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text("OR", style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color)),
                const SizedBox(height: 20),
                InkWell(
                  onTap: googleSignIn,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/google.png'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                    text: TextSpan(
                        text: "No Account ?  ",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                        children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickedSignUp,
                          text: "Sign Up",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.onPrimary))
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }

  googleSignIn() async {
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }
  }
}
