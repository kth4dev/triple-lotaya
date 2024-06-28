import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/collections.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/bloc/account/account_bloc.dart';
import 'package:lotaya/presentation/screens/match/widget/IconLabelBox.dart';

import '../../../core/styles/dialogs/confirm_dialog.dart';
import '../../../data/model/user.dart';

class CreateMatchWidget extends StatefulWidget {
  const CreateMatchWidget({Key? key}) : super(key: key);

  @override
  State<CreateMatchWidget> createState() => _CreateMatchWidgetState();
}

class _CreateMatchWidgetState extends State<CreateMatchWidget> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedAMCloseTime;
  late TextEditingController amBreakAmountController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoadingState) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is AccountLoadedState) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(
              width: 1,
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: openDatePicker,
                          child: IconLabelBox(
                            label: DateFormat('dd-MM-yyyy').format(_selectedDate),
                            iconData: Icons.calendar_today,
                            color: Colors.black,
                          )),
                      10.paddingHeight,
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: DefaultText("Close :", style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w500)),
                          ),
                          TextButton(
                              onPressed: () async {
                                TimeOfDay? time = await openTimePicker(_selectedAMCloseTime);
                                if (time != null) {
                                  _selectedAMCloseTime = time;
                                }
                                setState(() {});
                              },
                              child: IconLabelBox(
                                label: _selectedAMCloseTime.format(context),
                                iconData: Icons.access_time_rounded,
                                color: Colors.black,
                              )),
                        ],
                      ),
                      5.paddingHeight,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutLinedTextField(controller: amBreakAmountController, label: "Break Amount", textInputType: TextInputType.number),
                      )
                    ],
                  ),
                ),
                PrimaryButton(
                    onPressed: () {
                      showConfirmDialog(
                          context: context,
                          title: "Create Match",
                          content: "Are you sure you want to create matches",
                          onPressedConfirm: () {
                            Navigator.of(context).pop();
                            createMatches(inAccounts: state.inAccountList, outAccounts: state.outAccountList);
                          });
                    },
                    label: "သိမ်းမည်")
              ],
            ),
          );
        }
        if (state is AccountErrorState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DefaultText("Fail To Get Players", style: TextStyles.descriptionTextStyle),
              10.paddingHeight,
              IconButton(
                  onPressed: () {
                    BlocProvider.of<AccountBloc>(context).add(GetAccountsEvent());
                  },
                  icon: const Icon(Icons.refresh))
            ],
          );
        }

        return const DefaultText("Something went wrong!", style: TextStyles.descriptionTextStyle);
      },
    );
  }

  Future<void> createMatches({required List<Account> inAccounts, required List<Account> outAccounts}) async {
    showLoadingDialog(context: context, title: "Create Match", content: "creating...");
    FirebaseFirestore.instance
        .collection(Collections.match)
        .doc(DateFormat('dd-MM-yyyy').format(_selectedDate))
        .set(DigitMatch(
            date: DateFormat('dd-MM-yyyy').format(_selectedDate),
            inAccounts: inAccounts,
            outAccounts: outAccounts,
            closeTime: _selectedDate.copyWith(hour: _selectedAMCloseTime.hour, minute: _selectedAMCloseTime.minute).millisecondsSinceEpoch,
            isActive: false,
            createdDate: DateTime.now().millisecondsSinceEpoch,
            breakAmount: int.parse(amBreakAmountController.text.toString()),
            digitPermission: []).toJson())
        .then((value) {
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Created AM Match Successfully");
    }).catchError((error) {
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Failed to create Match: $error");
    });
  }

  void openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(DateTime.now().year), lastDate: DateTime(DateTime.now().year + 5));
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate; //set output date to TextField value.
      });
    }
  }

  Future<TimeOfDay?> openTimePicker(TimeOfDay timeOfDay) async {
    final TimeOfDay? time = await showTimePicker(context: context, initialTime: timeOfDay, initialEntryMode: TimePickerEntryMode.input);
    return time;
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AccountBloc>(context).add(GetAccountsEvent());
    _selectedDate = DateTime.now();
    _selectedAMCloseTime = TimeOfDay.now().replacing(hour: 11, minute: 50);
    amBreakAmountController = TextEditingController();

    amBreakAmountController.text = "35000";
  }

  @override
  void dispose() {
    super.dispose();
    amBreakAmountController.dispose();
  }
}
