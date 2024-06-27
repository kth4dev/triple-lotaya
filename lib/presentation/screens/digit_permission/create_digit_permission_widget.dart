import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/dialogs/info_dialog.dart';
import 'package:lotaya/core/styles/dialogs/loading_dialog.dart';
import 'package:lotaya/data/model/digit_permission.dart';
import 'package:lotaya/data/model/match.dart';

import '../../../core/styles/buttons/primary_button.dart';
import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textfields/outline_textfield.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/collections.dart';
import '../../../data/model/user.dart';
import '../../bloc/account/account_bloc.dart';

class CreateDigitPermission extends StatefulWidget {
  final List<Account> accounts;
  final DigitMatch selectedMatch;

  const CreateDigitPermission({Key? key, required this.accounts, required this.selectedMatch}) : super(key: key);

  @override
  State<CreateDigitPermission> createState() => _CreateDigitPermissionState();
}

class _CreateDigitPermissionState extends State<CreateDigitPermission> {
  late TextEditingController digitPermissionController, totalPermissionController;
  String _selectedReferUser = '';

  @override
  void initState() {
    super.initState();
    digitPermissionController = TextEditingController();
    totalPermissionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReferUser(),
            OutLinedTextField(controller: digitPermissionController, label: "၁ကွက် ထိုးကြေး", textInputType: TextInputType.number),
            OutLinedTextField(controller: totalPermissionController, label: "ထိုးကြေး စုစုပေါင်း", textInputType: TextInputType.number),
            PrimaryButton(
                onPressed: () {
                  if (num.tryParse(digitPermissionController.text) != null && num.tryParse(totalPermissionController.text) != null) {
                    updateMatches();
                  }
                },
                label: "သိမ်းရန်")
          ],
        ),
      ),
    );
    ;
  }

  Widget _buildReferUser() {
    List<String> userNames = ["All"];
    userNames.addAll(widget.accounts.map((e) => e.name).toList());
    if(_selectedReferUser.isEmpty){
      _selectedReferUser=userNames.first;
    }
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: UnderLineDropDownButton(
          initialValue: _selectedReferUser,
          values: userNames,
          label: "User",
          onChange: (String? newValue) {
            if (newValue != null) {
              _selectedReferUser = newValue;
            }
          },
        ),
      ),
    );
  }

  Future<void> updateMatches() async {
    showLoadingDialog(context: context, title: "Add Permission", content: "Loading...");
    int index = getUserIndex();
    if (index == -1) {
      widget.selectedMatch.digitPermission
          .add(DigitPermission(digitPermission: int.parse(digitPermissionController.text), totalPermission: int.parse(totalPermissionController.text), user: _selectedReferUser));
    } else {
      widget.selectedMatch.digitPermission[index] =
          DigitPermission(digitPermission: int.parse(digitPermissionController.text), totalPermission: int.parse(totalPermissionController.text), user: _selectedReferUser);
    }
    FirebaseFirestore.instance.collection(Collections.match).doc(widget.selectedMatch.matchId).set(widget.selectedMatch.toJson()).then((value) {
      Navigator.of(context).pop();
      digitPermissionController.text="";
      totalPermissionController.text="";
    }).catchError((error) {
      showInfoDialog(context: context, title: "Failed", content: "Failed to add permission");
      Navigator.of(context).pop();
    });
  }

  int getUserIndex() {
    for (var index = 0; index < widget.selectedMatch.digitPermission.length; index++) {
      if (widget.selectedMatch.digitPermission[index].user == _selectedReferUser) {
        return index;
      }
    }
    return -1;
  }
}
