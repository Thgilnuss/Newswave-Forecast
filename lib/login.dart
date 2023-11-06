import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'register.dart';
import 'main.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      backgroundColor: Colors.white.withAlpha(10000),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LoginForm(),
              SizedBox(height: 20.0),

              TimeBasedShape(),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeBasedShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;

    Widget shape = (currentHour >= 6 && currentHour < 17)
        ? Icon(Icons.wb_sunny, size: 300.0, color: Colors.orange)
        : Transform.rotate(
      angle: 30 * 3.14 / 180,
      child: Icon(Icons.brightness_2, size: 300.0, color: Colors.blue),
    );

    Color cloudColor = (currentHour >= 6 && currentHour < 17) ? Colors.white : Colors.grey;

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.yellow,
      ),
      child: Stack(
        children: [
          Positioned(left: 10, top: 70, child: _buildCloud(cloudColor)),
          Positioned(right: 1, top: 10, child: _buildCloud(cloudColor)),
          Positioned(left: 50, bottom: -15, child: _buildCloud(cloudColor)),
          Positioned(right: 10, bottom: 10, child: _buildCloud(cloudColor)),
          shape,
        ],
      ),
    );
  }

  Widget _buildCloud(Color color) {
    return Icon(
      Icons.cloud,
      size: 80.0,
      color: color,
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _authenticateUser() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'inus-users.ckjforryv7ff.ap-southeast-1.rds.amazonaws.com',
      port: 3306,
      user: 'admin',
      password: '01234567',
      db: 'weather_news',
    ));

    try {
      final result = await conn.query(
          'SELECT * FROM Users WHERE Username = ? AND Password = ?',
          [_usernameController.text, _passwordController.text]);

      if (result.isEmpty) {
        _showAlertDialog('Error', 'Please confirm the details.');
      } else {
        // Navigate to WeatherApp screen on successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WeatherApp()),
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      await conn.close();
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.grey.withAlpha(500),
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.blue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Username';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.blue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState != null &&
                  _formKey.currentState!.validate()) {
                _authenticateUser();
              }
            },
            child: Text(
              'Login',
              style: TextStyle(fontSize: 14.0),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue.withOpacity(0.8),
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          SizedBox(height: 16.0),
          Text(
            "Don't have an account?",
          style: TextStyle(
            color: Colors.white
          ),),
          TextButton(
            onPressed: _navigateToRegisterScreen,
            child: Text('Sign up'),
          ),
        ],
      ),
    );
  }
}
