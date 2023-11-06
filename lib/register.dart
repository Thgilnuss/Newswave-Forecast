import 'package:flutter/material.dart';
import 'login.dart';
import 'package:mysql1/mysql1.dart';


class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
      ),
      backgroundColor: Colors.white.withAlpha(10000),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RegisterForm(),
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

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _addUserToDatabase(String username, String password) async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'inus-users.ckjforryv7ff.ap-southeast-1.rds.amazonaws.com',
      port: 3306,
      user: 'admin',
      password: '01234567',
      db: 'weather_news',
    ));

    try {
      final result = await conn.query('SELECT * FROM Users WHERE Username = ?', [username]);

      if (result.isNotEmpty) {
        _showUsernameExistsDialog();
        print('Username already exists.');
      } else {
        final insertResult = await conn.query(
            'INSERT INTO Users (Username, Password) VALUES (?, ?)', [username, password]);

        if (insertResult.affectedRows == 1) {
          _showSuccessDialog();
          print('User added successfully.');
        } else {
          print('Failed to add user.');
        }
      }
    } finally {
      await conn.close();
    }
  }

  void _showUsernameExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.grey.withAlpha(500),
          title: Text('Opps :('),
          content: Text('This name already has a user. Please choose another Username.'),
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


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.grey.withAlpha(500),
          content: Text('Successfully'),
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

  void _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
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
              if (value.length < 5) {
                return 'The Username must be at least 5 characters.';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
              ),
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
                return 'Please enter a Password';
              }
              if (value.length < 8) {
                return 'Minimum 8 characters for the Password (letters and numbers included).';
              }
              bool hasLetter = false;
              bool hasDigit = false;
              for (var i = 0; i < value.length; i++) {
                if (value[i].toLowerCase() != value[i].toUpperCase()) {
                  hasLetter = true;
                }
                if (int.tryParse(value[i]) != null) {
                  hasDigit = true;
                }
                if (hasLetter && hasDigit) {
                  break;
                }
              }
              if (!hasLetter || !hasDigit) {
                return 'Password requires both letters and numbers.';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm password',
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
              if (value != _passwordController.text) {
                return 'Confirmation Password does not match.';
              }
              return null;
            },
          ),
          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState != null &&
                  _formKey.currentState!.validate()) {
                _addUserToDatabase(_usernameController.text, _passwordController.text);
              }
            },
            child: Text(
              'Sign up',
              style: TextStyle(fontSize: 14.0),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.white.withOpacity(0.8),
              onPrimary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),

          SizedBox(height: 16.0),
          Text(
            'Already have an account?',
            style: TextStyle(
                color: Colors.white
            ),
          ),
          TextButton(
            onPressed: _navigateToLoginScreen,
            child: Text('Login'),
            ),
        ],
      ),
    );
  }
}


