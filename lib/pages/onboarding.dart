import 'dart:ffi';
import '../components/text.dart';
import '../components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../components/crud.dart';
import '../components/firebase_func.dart';

class onboarding extends StatefulWidget {
  const onboarding({super.key});

  @override
  State<onboarding> createState() => _onboardingState();
}

class _onboardingState extends State<onboarding>
    with SingleTickerProviderStateMixin {
  late var check;
  var currentuser = null;
  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool constr = false;
      if (constraints.maxWidth > 600) constr = true;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (constraints.maxWidth < 600)
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 0),
                      child: CircleAvatar(
                        radius: 30,
                        child: Image.asset(
                          "assets/serenova.png",
                          fit: BoxFit.cover,
                        ),
                        // backgroundImage: ExactAssetImage("assets/psychsail_600.png")
                        backgroundColor: Color(0xFFFFFF),
                      )),
                if (constraints.maxWidth < 600)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 0),
                    child: Text("Serenova"),
                  )
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: sizeHeight / 20),
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/background_onboarding.png"),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 32.0, right: 32.0, top: sizeHeight / 50),
                  child: Container(
                    // alignment: Alignment.center,
                    child: Center(
                      child: Text(
                        constr
                            ? 'Sail Through Tough Times with Serenova'
                            : 'Sail Through Tough Times \n with Serenova.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: constr ? sizeWidth / 30 : sizeHeight / 17,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'AkayaKanadaka'),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
                if (constraints.maxWidth < 600)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: HigthlightText(sizeHeight / 50, sizeHeight / 15,
                          "Chill Maps, Therapy Chats - Because\nSuccess Shouldn't Stress You Out!")),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sizeWidth / 10),
                  child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: sizeWidth / 10),
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
                                    ""),
                                if (check != {})
                                  {
                                    Navigator.pushNamed(context, '/home',
                                        arguments: {'currentuser': currentuser})
                                  }
                              },
                              child: circleButton(constr, sizeWidth / 200,
                                  sizeWidth / 100, "assets/google.png"),
                            ),
                            InkWell(
                              onTap: () async => {},
                              child: circleButton(constr, sizeWidth / 200,
                                  sizeWidth / 100, "assets/apple.png"),
                            ),
                          ],
                        ),
                      )),
                ),
                divider(constr, sizeWidth / 30, sizeWidth / 20, Colors.white),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constr ? sizeWidth / 5 : sizeWidth / 10),
                  child: InkWell(
                      onTap: () => {Navigator.pushNamed(context, '/Signup')},
                      child: bottomButton(
                          constr,
                          sizeWidth / 50,
                          sizeHeight / 50,
                          "Sign up with mail",
                          Colors.white,
                          Colors.black)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constr ? sizeWidth / 5 : sizeWidth / 10),
                  child: InkWell(
                    onTap: () => {Navigator.pushNamed(context, '/login')},
                    child: bottomButton(
                        constr,
                        sizeWidth / 50,
                        sizeHeight / 50,
                        "Existing account? Log in",
                        Colors.transparent,
                        Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
