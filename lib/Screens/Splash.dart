import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:wp_visualizer/Screens/DashBord/dashboard_screen.dart';

import '../Colors/ColorDecider.dart';
import '../Colors/ThemeChange.dart';
import '../Controller/Fetching Api/user_information.dart';
import '../Model/UserData.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var userNameController = TextEditingController();
  int userNameValidation = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var theme = Provider.of<ThemeChange>(context, listen: true);
    Color primaryColor = Theme.of(context).primaryColor;
    Color defaultPrimaryColor = Colors.cyan;
    Color defaultaccent = Colors.black;
    var userNameInputTextBox = TextField(
      cursorColor: defaultPrimaryColor,
      decoration: InputDecoration(
          labelText: 'User Name',
          prefixIcon:IconTheme(
            data: IconThemeData(color: defaultPrimaryColor),
            child: Icon(Icons.person),
          ),
          // focusColor: defaultPrimaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.cyan, width: 2.0),
          ),
          labelStyle: TextStyle(color: defaultPrimaryColor),
          border: OutlineInputBorder(),
          errorText: errorTextShow(userNameValidation),
          
      ),
      autofocus: true,
      controller: userNameController,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_-_]")),
      ],
      onChanged: (_) {
        onChangeUserName();
      },
    );
    return Scaffold(
      body: Container(
        height: size.height * 0.8,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Image.asset(
                "images/splas.png",
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: size.width,
              child: Text(
                "Pls enter you codeforces profile",
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            userNameInputTextBox,
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: size.width,
              child: ProgressButton(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                strokeWidth: 1,
                color: Colors.cyan,
                child: Text(
                  "Shaw Data",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: (AnimationController animationController) async {
                  await fetchData(userNameController, animationController);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  errorTextShow(int userNameValidation) {
    if (userNameValidation == -1)
      return "Internet Not Stable";
    else if (userNameValidation == -2)
      return "Invalid UserName";
    else if (userNameValidation == -3) return "Server Error :(";
    return null;
  }

  fetchData(TextEditingController userNameController,
      AnimationController animationController) async {
    String userName = userNameController.text;
    animationController.forward();
    bool connection = await connectivityChk();
    if (connection) {
      print(userName);
      UserData dashBoard = await dashBoardData(userName);
      if (dataCopletionChk(dashBoard)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Dashboard(userData: dashBoard)));
      }
    }
    animationController.reset();
  }

  Future<bool> connectivityChk() async {
    try {
      final ConnectivityResult result =
          await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        userNameValidation = 0;
      } else {
        userNameValidation = -1;
      }
      setState(() {
        userNameValidation;
      });
      return userNameValidation == 0;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  onChangeUserName() {
    if (userNameValidation != 0) {
      userNameValidation = 0;
      setState(() {
        userNameValidation;
      });
    }
  }

  Future<UserData> dashBoardData(String handle) async {
    try {
      return await UserInfo(handle: handle).fetchUserInfo();
    } on Exception catch (e) {
      print("exeception");
    }
    return UserData.status(status: "Server Error");
  }

  bool dataCopletionChk(UserData dashBoard) {
    userNameValidation = 0;
    if (dashBoard.status == "FAILED") {
      userNameValidation = -2;
    } else if (dashBoard.status == "Server Error") {
      userNameValidation = -3;
    }
    if (userNameValidation != 0) {
      setState(() {
        userNameValidation;
      });
    }
    return userNameValidation == 0;
  }

  changeTheme(String s) {
    // theme=;
  }
}
