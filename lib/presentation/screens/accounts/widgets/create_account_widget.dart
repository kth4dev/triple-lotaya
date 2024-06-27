import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/core/styles/textstyles/textfields_utils.dart';
import 'package:lotaya/data/model/user.dart';

class CreateAccountWidget extends StatefulWidget {
  final Stream<QuerySnapshot> accountsStream;

  const CreateAccountWidget({Key? key, required this.accountsStream}) : super(key: key);

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  late TextEditingController nameController, passwordController, commissionController, percentController;
  String _userTypeValue = "account";

  TextEditingController commentTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    passwordController = TextEditingController();
    commissionController = TextEditingController();
    percentController = TextEditingController();
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
            Wrap(
              children: [
                _buildUserTypeRadioButton(userType: "account", label: "အကောင့်"),
                _buildUserTypeRadioButton(userType: "input", label: "ထိုးသား"),
                _buildUserTypeRadioButton(userType: "output", label: "တင်ဒိုင်"),
              ],
            ),
            _buildReferUser,
            Row(
              children: [
                Expanded(
                  child: OutLinedTextField(controller: nameController, label: "Name", textInputType: TextInputType.text),
                ),
                5.paddingWidth,
                Expanded(
                  child: OutLinedTextField(controller: passwordController, label: "Password", textInputType: TextInputType.text),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: OutLinedTextField(controller: commissionController, label: "2D ကော်", textInputType: TextInputType.number),
                ),
                5.paddingWidth,
                Expanded(
                  child: OutLinedTextField(controller: percentController, label: "2D အလျော်အဆ", textInputType: TextInputType.number),
                ),
              ],
            ),
            PrimaryButton(
                onPressed: () {
                  if (!TextFieldsUtils.isTextFieldsEmpty([nameController, passwordController, commissionController, percentController])) {
                    createUser();
                  } else {
                    Toasts.showErrorMessageToast("Please Fill Completely");
                  }
                },
                label: "သိမ်းရန်")
          ],
        ),
      ),
    );
  }

  String _selectedReferUser = '';

  Widget get _buildReferUser =>
      StreamBuilder<QuerySnapshot>(
        stream: widget.accountsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.data!.size == 0) {
            return const DefaultText("Refer User : No Data", style: TextStyles.bodyTextStyle);
          }else{
            List<String> accounts = [];
            snapshot.data!.docs.map((DocumentSnapshot document) {
              accounts.add(document.id);
            }).toList();
            if(accounts.isNotEmpty){
              _selectedReferUser=accounts[0];
              return Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: UnderLineDropDownButton(
                    initialValue: accounts[0],
                    values: accounts,
                    label: "Refer User",
                    onChange: (String? newValue) {
                      if (newValue != null) {
                        _selectedReferUser=newValue;
                      }
                    },
                  ),
                ),
              );
            }
            return const DefaultText("Refer User : No Data", style: TextStyles.bodyTextStyle);
          }
        },
      );

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    passwordController.dispose();
    commissionController.dispose();
    percentController.dispose();
  }

  Future<void> createUser() async {
    showLoadingDialog(context: context, title: "Create User", content: "creating...");
    FirebaseFirestore.instance
        .collection('users')
        .doc(nameController.text.toString())
        .set(Account(
        name: nameController.text.toString(),
        password: passwordController.text.toString(),
        commission: int.parse(commissionController.text.toString()),
        percent: int.parse(percentController.text.toString()),
        type: _userTypeValue,
        referUser: _selectedReferUser,
        createdDate: DateTime.now().millisecondsSinceEpoch)
        .toJson())
        .then((value) {
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Success");
      TextFieldsUtils.clearText([nameController, passwordController, commissionController, percentController]);
    }).catchError((error) {
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Failed to add user: $error");
    });
  }

  Widget _buildUserTypeRadioButton({required String userType, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: userType,
          groupValue: _userTypeValue,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _userTypeValue = value;
              });
            }
          },
        ),
        DefaultText(label, style: TextStyles.bodyTextStyle)
      ],
    );
  }
}
