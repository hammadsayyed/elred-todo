import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_crud/main.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _SignUpWidgetPageState createState() => _SignUpWidgetPageState();
}

class _SignUpWidgetPageState extends State<SignUpWidget> {

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print("Sign up catch");
      print(e);
      final snackBar = SnackBar(
        content:
            Text(e.message.toString(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Sign up',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lato(textStyle:const TextStyle(color: Colors.blue, fontSize: 50, fontWeight: FontWeight.w400))),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) {
                    // Check if this field is empty
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) =>
                      val != null && val.length < 6 ? "Enter min 6 char" : null,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: signUp,
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                    text:
                        TextSpan(text: "Already Have an account ?  ", 
                        style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1!.color),
                        children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: "Sign In",
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
}
