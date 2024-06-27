
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/core/styles/textstyles/textfields_utils.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/data/collections.dart';
import 'package:lotaya/presentation/screens/home/home_screen.dart';
import 'package:oktoast/oktoast.dart';

import '../../../core/routes/routes.dart';
import '../../../core/styles/buttons/primary_button.dart';
import '../../../core/styles/dialogs/info_dialog.dart';
import '../../../core/styles/dialogs/loading_dialog.dart';
import '../../../core/styles/textfields/icon_password_textfield.dart';
import '../../../core/styles/textfields/icon_textfield.dart';
import '../../../data/model/user.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController userNameController ,passwordController;


  @override
  void initState() {
    super.initState();
    userNameController=TextEditingController();
    passwordController=TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9FBCA),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.2,
                ),
                headerWidget,
                formWidget,
              ],
            ),
          ),
        ),
      )
    );
  }

  logIn(String userId,String password){
    showLoadingDialog(context: context, title: "Log In", content: "Loading...");
    FirebaseFirestore.instance.collection(Collections.user).doc(userId).get().then((document){
      Navigator.of(context).pop();
      if(document.exists){
        final account= Account.fromJson(document.data()!);
        if(account.password==password){
          CacheHelper.saveAccountInfo(account);
          goToNextPageFinish(context,const HomeScreen());
        }else{
          showInfoDialog(context: context, title: "Failed", content: "Wrong Password!");
        }
      }else{
        showInfoDialog(context: context, title: "Failed", content: "User not found!");
      }
    }).catchError((error){
      Navigator.of(context).pop();
      showInfoDialog(context: context, title: "Failed", content: error.toString());
    });
  }


  Widget get headerWidget {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Lotaya',
          style: TextStyle(letterSpacing: 1.5, color: Colors.green, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        5.paddingHeight,
        const Text(
          'Login to your account',
          style: TextStyle(color: Colors.green, fontSize: 22),
        ),
      ],
    );
  }

  Widget get formWidget {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: MediaQuery.of(context).size.width*0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTextField(iconData: Icons.account_box, label: "Enter user name", controller: userNameController),
          10.paddingHeight,
          IconPasswordTextField(iconData: Icons.lock, label: "Enter password", controller: passwordController),
          5.paddingHeight,
          PrimaryButton(onPressed: () {
              if(!TextFieldsUtils.isTextFieldsEmpty([userNameController,passwordController])){
                logIn(userNameController.text.toString(), passwordController.text.toString());
              }else{
             //   Toasts.showInfoToast("Please fill completely");
                showToast("Please fill completely",position: ToastPosition.bottom);
              }
          }, label: "Log in")
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    passwordController.dispose();
  }
}
