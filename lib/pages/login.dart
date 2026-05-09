import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../components/text.dart';
import '../components/button.dart';
import '../components/firebase_func.dart';
import '../components/crud.dart';
import './home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var check = null;
  var currentuser = null;
  var position = null;
  late final nameController = TextEditingController();
  late final emailController = TextEditingController();
  late final passwordController = TextEditingController();
  final error = ValueNotifier(false);
  // FirebaseFirestore _firestore = FirebaseFirestore.instance ;
  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool constr = false;
      if (constraints.maxWidth > 600) constr = true;
      // Position position ;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizeWidth / 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: sizeHeight / 15),
                  child: Text(
                    "Log In",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 10,
                        decorationColor:
                            Color.fromRGBO(35, 154, 139, 75).withOpacity(0.4),
                        fontSize: constr ? sizeWidth / 50 : sizeWidth / 20,
                        color: Colors.black),
                  ),
                ),
                if (!constr)
                  greyText(sizeHeight / 50, sizeHeight / 15,
                      "Welcome back! Sign in using your social\naccount or email to continue us"),
                if (!constr)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: sizeWidth / 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () async =>
                                  {print(await signInWithFacebook())},
                              child: circleButton(constr, sizeWidth / 200,
                                  sizeWidth / 100, "assets/facebook.png"),
                            ),
                            InkWell(
                              onTap: () async => {
                                check = await signInWithGoogle(),
                                currentuser = await (check)
                                    .additionalUserInfo
                                    .profile['given_name'],
                                check = await createRecord(
                                    (check)
                                        .additionalUserInfo
                                        .profile['given_name'],
                                    (check).additionalUserInfo.profile['email'],
                                    (check)
                                        .additionalUserInfo
                                        .profile['given_name'],
                                    "1"),
                                if (check != {})
                                  Navigator.pushNamed(context, '/home',
                                      arguments: {'currentuser': currentuser})
                              },
                              child: circleButton(constr, sizeWidth / 200,
                                  sizeWidth / 100, "assets/google.png"),
                            ),
                            InkWell(
                              onTap: () async => {},
                              child: circleButton(constr, sizeWidth / 200,
                                  sizeWidth / 100, "assets/black_apple.png"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: sizeWidth / 20),
                        child: divider(constr, sizeWidth / 30, sizeWidth / 20,
                            Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: sizeHeight / 8,
                            left: sizeWidth / 20,
                            right: sizeWidth / 20),
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(color: Colors.black),
                              controller: emailController,
                              onChanged: (newValue) =>
                                  emailController.text = newValue,
                              decoration: logininput(
                                  'Enter your email', "Ex- john@gmail.com"),
                            ),
                            TextFormField(
                              style: TextStyle(color: Colors.black),
                              controller: nameController,
                              onChanged: (newValue) =>
                                  nameController.text = newValue,
                              decoration:
                                  logininput('Enter your name', "Ex- john"),
                            ),
                            TextFormField(
                              style: TextStyle(color: Colors.black),
                              controller: passwordController,
                              onChanged: (newValue) =>
                                  passwordController.text = newValue,
                              obscureText: true,
                              decoration:
                                  logininput('Password', "Ex- John123g#"),
                            ),
                            if (error.value)
                              Text(
                                "Missing values. Please try again",
                                style: TextStyle(color: Colors.red),
                              ),
                            if (check == 'IncorrectDetails')
                              Text("User details do not match",
                                  style: TextStyle(color: Colors.red))
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sizeWidth / 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () async =>
                                      {print(await signInWithFacebook())},
                                  child: circleButton(constr, sizeWidth / 200,
                                      sizeWidth / 100, "assets/facebook.png"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () async {
                                    check = await signInWithGoogle();
                                    currentuser = await (check)
                                        .additionalUserInfo
                                        .profile['given_name'];
                                    check = await createRecord(
                                        (check)
                                            .additionalUserInfo
                                            .profile['given_name'],
                                        (check)
                                            .additionalUserInfo
                                            .profile['email'],
                                        (check)
                                            .additionalUserInfo
                                            .profile['given_name'],
                                        "");
                                    if (check != {}) {
                                      position ??= await _determinePosition();

                                      if (position != null) {
                                        // Ensure position is available before navigating
                                        Navigator.pushNamed(context, '/home',
                                            arguments: {
                                              'currentuser': currentuser,
                                              'position': position,
                                            });
                                      } else {
                                        print(
                                            "Position is null"); // Debugging statement
                                        // Handle the case where position is null
                                      }
                                    }
                                  },
                                  child: circleButton(constr, sizeWidth / 200,
                                      sizeWidth / 100, "assets/google.png"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () async => {},
                                  child: circleButton(
                                      constr,
                                      sizeWidth / 200,
                                      sizeWidth / 100,
                                      "assets/black_apple.png"),
                                ),
                              ),
                            ],
                          ),
                          dividervertical(constr, sizeHeight / 7,
                              sizeHeight / 20, Colors.black),
                          Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: sizeWidth / 2,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: sizeWidth / 4.3,
                                      ),
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.black),
                                        controller: emailController,
                                        onChanged: (newValue) =>
                                            emailController.text = newValue,
                                        decoration: logininput(
                                            'Enter your email',
                                            "Ex- john@gmail.com"),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: sizeWidth / 4.3,
                                        ),
                                        child: TextFormField(
                                          controller: nameController,
                                          onChanged: (newValue) =>
                                              nameController.text = newValue,
                                          style: TextStyle(color: Colors.black),
                                          decoration: logininput(
                                              'Enter your name', "Ex- john"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: sizeWidth / 2,
                                ),
                                child: TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  controller: passwordController,
                                  onChanged: (newValue) =>
                                      passwordController.text = newValue,
                                  obscureText: true,
                                  decoration:
                                      logininput('Password', "Ex- John123g#"),
                                ),
                              ),
                              if (error.value)
                                Text("Missing values. Please try again",
                                    style: TextStyle(color: Colors.red)),
                              if (check == 'IncorrectDetails')
                                Text("User details do not match",
                                    style: TextStyle(color: Colors.red))
                            ],
                          ),
                        ]),
                  ),
                constr
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: sizeWidth / 20, right: sizeWidth / 20),
                              child: InkWell(
                                onTap: () async {
                                  if (nameController.text == "" ||
                                      passwordController.text == "" ||
                                      emailController.text == "") {
                                    error.value = true;
                                  } else {
                                    print(nameController.text);
                                    check = await checkUser(
                                        nameController.text,
                                        emailController.text,
                                        passwordController.text);
                                    if (check == 'userExists') {
                                      position = await _determinePosition();
                                      print(position);
                                      //   Navigator.pushNamed(context, '/home',
                                      //       arguments: {
                                      //         'currentuser': nameController.text,
                                      //         'position': position
                                      //       });
                                    }
                                  }
                                },
                                child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: sizeWidth / 2,
                                    ),
                                    child: bottomButton(
                                        constr,
                                        sizeWidth / 50,
                                        sizeHeight / 50,
                                        "Log in",
                                        Color.fromRGBO(35, 154, 139, 75),
                                        Colors.white)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: sizeWidth / 20, right: sizeWidth / 20),
                              child: bottomButton(
                                  constr,
                                  sizeWidth / 50,
                                  sizeHeight / 50,
                                  "Forgot Password?",
                                  Colors.transparent,
                                  Color.fromRGBO(35, 154, 139, 75)),
                            )
                          ])
                    : Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: sizeWidth / 20, right: sizeWidth / 20),
                            child: InkWell(
                                onTap: () async {
                                  if (nameController.text == "" ||
                                      passwordController.text == "" ||
                                      emailController.text == "") {
                                    setState(() {
                                      error.value = true;
                                    });
                                  } else {
                                    check = await checkUser(
                                        nameController.text,
                                        emailController.text,
                                        passwordController.text);
                                    if (check == 'userExists') {
                                      position = await _determinePosition();
                                      print(position.toJson()['longitude']);
                                      Navigator.pushNamed(context, '/home',
                                          arguments: {
                                            'currentuser': nameController.text,
                                            'positionLong':
                                                position.toJson()['longitude'],
                                            'positionLat':
                                                position.toJson()['latitude']
                                          });
                                    }
                                  }
                                  print(error);
                                },
                                child: bottomButton(
                                    constr,
                                    sizeWidth / 50,
                                    sizeHeight / 50,
                                    "Log in",
                                    Color.fromRGBO(38, 166, 149, 1),
                                    Colors.white)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: sizeWidth / 20, right: sizeWidth / 20),
                            child: bottomButton(
                                constr,
                                sizeWidth / 50,
                                sizeHeight / 50,
                                "Forgot Password?",
                                Colors.transparent,
                                Color.fromRGBO(35, 154, 139, 75)),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
