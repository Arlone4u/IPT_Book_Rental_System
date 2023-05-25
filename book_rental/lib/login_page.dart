import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  late AnimationController controller1;
  late AnimationController controller2;
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late Animation<double> animation4;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  void _submitLoginForm(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .login(username, password);

        // Show pop-up message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Successful'),
              content: Text('You have successfully logged in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/Home');
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to login. Please try again.'),
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );
    animation1 = Tween<double>(begin: .1, end: .15).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller1.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller1.forward();
        }
      });
    animation2 = Tween<double>(begin: .02, end: .04).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    controller2 = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );
    animation3 = Tween<double>(begin: .41, end: .38).animate(CurvedAnimation(
      parent: controller2,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller2.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller2.forward();
        }
      });
    animation4 = Tween<double>(begin: 170, end: 190).animate(
      CurvedAnimation(
        parent: controller2,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    Timer(Duration(milliseconds: 2500), () {
      controller1.forward();
    });

    controller2.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff192028),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                Positioned(
                  top: size.height * (animation2.value + .58),
                  left: size.width * .21,
                  child: CustomPaint(
                    painter: MyPainter(50),
                  ),
                ),
                Positioned(
                  top: size.height * .98,
                  left: size.width * .1,
                  child: CustomPaint(
                    painter: MyPainter(animation4.value - 30),
                  ),
                ),
                Positioned(
                  top: size.height * .5,
                  left: size.width * (animation2.value + .8),
                  child: CustomPaint(
                    painter: MyPainter(30),
                  ),
                ),
                Positioned(
                  top: size.height * animation3.value,
                  left: size.width * (animation1.value + .1),
                  child: CustomPaint(
                    painter: MyPainter(60),
                  ),
                ),
                Positioned(
                  top: size.height * .1,
                  left: size.width * .8,
                  child: CustomPaint(
                    painter: MyPainter(animation4.value),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.only(top: size.height * .1),
                        child: Text(
                          'Book Rental',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            wordSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          userName(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              loginbtn('LOGIN', 2.58, () {
                                HapticFeedback.lightImpact();
                                Fluttertoast.showToast(
                                    msg: 'Login button pressed');
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          registerbtn(
                            'Create a new Account',
                            2,
                            () {
                              HapticFeedback.lightImpact();
                              Fluttertoast.showToast(
                                  msg: 'Create a new account button pressed');
                            },
                          ),
                          SizedBox(height: size.height * .05),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userName() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaY: 15,
                sigmaX: 15,
              ),
              child: Container(
                height: size.width / 8,
                width: size.width / 1.2,
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: size.width / 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.30),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.white.withOpacity(.9)),
                  cursorColor: Colors.white,
                  obscureText: false,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      textBaseline: TextBaseline
                          .alphabetic, // Align the baseline of the error message
                      decoration:
                          TextDecoration.none, // Remove any text decoration
                      fontWeight:
                          FontWeight.normal, // Set the font weight to normal
                      letterSpacing: 1.0, // Adjust letter spacing if needed
                      wordSpacing: 1.0,
                    ),
                    prefixIcon: Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white.withOpacity(.7),
                    ),
                    border: InputBorder.none,
                    hintMaxLines: 1,
                    hintText: 'Username',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaY: 15,
                sigmaX: 15,
              ),
              child: Container(
                height: size.width / 8,
                width: size.width / 1.2,
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: size.width / 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.30),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white.withOpacity(.9)),
                  cursorColor: Colors.white,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      textBaseline: TextBaseline
                          .ideographic, // Align the baseline of the error message
                      decoration:
                          TextDecoration.none, // Remove any text decoration
                      fontWeight:
                          FontWeight.normal, // Set the font weight to normal
                      letterSpacing: 1.0, // Adjust letter spacing if needed
                      wordSpacing: 1.0, // Adjust word spacing if needed
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.white.withOpacity(.7),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _passwordVisible =
                              !_passwordVisible; // Toggle password visibility
                        });
                      },
                      child: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                    ),
                    border: InputBorder.none,
                    hintMaxLines: 1,
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginbtn(String string, double width, VoidCallback voidCallback) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => _submitLoginForm(context),
          child: Container(
            height: size.width / 8,
            width: size.width / width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white, // Define the border color
                width: 1.0, // Define the border width
              ),
            ),
            child: Text(
              string,
              style: TextStyle(color: Colors.white.withOpacity(.8)),
            ),
          ),
        ),
      ),
    );
  }

  Widget registerbtn(String string, double width, VoidCallback voidCallback) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: Container(
            height: size.width / 8,
            width: size.width / width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white, // Define the border color
                width: 1.0, // Define the border width
              ),
            ),
            child: Text(
              string,
              style: TextStyle(color: Colors.white.withOpacity(.8)),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double radius;

  MyPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
              colors: [Color(0xffFD5E3D), Color(0xffC43990)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(Rect.fromCircle(
        center: Offset(0, 0),
        radius: radius,
      ));

    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
