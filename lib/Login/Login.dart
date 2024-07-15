import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/navBarPage/NavBar.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _ChecBox = false;
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
      );

    }
  }

  Future<void> loginUser(String email, String password) async {
    final url = '${SabitD.URL}/api/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String? token = data['data']['token'];
      bool? is_admin = data['data']['is_admin'];
      bool? is_employee = data['data']['is_employee'];

      if (token != null) {
        if (_ChecBox) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setBool('is_admin', is_admin as bool);
          await prefs.setBool('is_employee', is_employee as bool);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
        );
      } else {
        print('Login failed: Token is null');
        print('Login failed: ${response.body}');
      }
    } else {
      print('Login failed: ${response.body}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                child: const RiveAnimation.asset("images/login.riv"),
              ),
              const SizedBox(height: 20),
               Text(
                AppLocalizations.of(context).translate("login.login"),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                  AppLocalizations.of(context).translate("login.Log_in_to_continue"),
                style:const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controllerEmail,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("login.email"),
                  prefixIcon: const Icon(FontAwesomeIcons.userAstronaut),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controllerPassword,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("login.password"),
                  prefixIcon: const Icon(FontAwesomeIcons.key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _ChecBox,
                    onChanged: (value) {
                      setState(() {
                        _ChecBox = !_ChecBox;
                      });
                    },
                  ),
                  Text( AppLocalizations.of(context).translate("login.Remind_me_next_time")),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _controllerEmail.text = "test@example.com";
                  _controllerPassword.text = "password";
                  loginUser(_controllerEmail.text, _controllerPassword.text);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(AppLocalizations.of(context).translate("login.Sign_in")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
