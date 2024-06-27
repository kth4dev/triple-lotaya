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
  late TimeOfDay _selectedAMOpenTime;
  late TimeOfDay _selectedAMCloseTime;
  late TimeOfDay _selectedPMOpenTime;
  late TimeOfDay _selectedPMCloseTime;
  late TextEditingController amBreakAmountController, pmBreakAmountController;

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
                TextButton(
                    onPressed: openDatePicker,
                    child: IconLabelBox(
                      label: DateFormat('dd-MM-yyyy').format(_selectedDate),
                      iconData: Icons.calendar_today,
                      color: Colors.black,
                    )),
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
                      DefaultText("AM", style: TextStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold)),
                      Divider(),
                      Wrap(
                        children: [
                          DefaultText("Open :", style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w500)),
                          TextButton(
                              onPressed: () async {
                                TimeOfDay? time = await openTimePicker(_selectedAMOpenTime);
                                if (time != null) {
                                  _selectedAMOpenTime = time;
                                }
                                setState(() {});
                              },
                              child: IconLabelBox(
                                label: _selectedAMOpenTime.format(context),
                                iconData: Icons.access_time_rounded,
                                color: Colors.black,
                              )),
                          DefaultText("Close :", style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w500)),
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
                      OutLinedTextField(controller: amBreakAmountController, label: "Break Amount", textInputType: TextInputType.number)
                    ],
                  ),
                ),
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
                      DefaultText("PM", style: TextStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold)),
                      const Divider(),
                      Wrap(
                        children: [
                          DefaultText("Open :", style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w500)),
                          TextButton(
                              onPressed: () async {
                                TimeOfDay? time = await openTimePicker(_selectedPMOpenTime);
                                if (time != null) {
                                  _selectedPMOpenTime = time;
                                }
                                setState(() {});
                              },
                              child: IconLabelBox(
                                label: _selectedPMOpenTime.format(context),
                                iconData: Icons.access_time_rounded,
                                color: Colors.black,
                              )),
                          DefaultText("Close :", style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w500)),
                          TextButton(
                              onPressed: () async {
                                TimeOfDay? time = await openTimePicker(_selectedPMCloseTime);
                                if (time != null) {
                                  _selectedPMCloseTime = time;
                                }
                                setState(() {});
                              },
                              child: IconLabelBox(
                                label: _selectedPMCloseTime.format(context),
                                iconData: Icons.access_time_rounded,
                                color: Colors.black,
                              )),
                        ],
                      ),
                      5.paddingHeight,
                      OutLinedTextField(controller: pmBreakAmountController, label: "Break Amount", textInputType: TextInputType.number)
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
    showLoadingDialog(context: context, title: "Create AM Match", content: "creating...");
    FirebaseFirestore.instance
        .collection(Collections.match)
        .doc("${DateFormat('dd-MM-yyyy').format(_selectedDate)} AM")
        .set(DigitMatch(
            date: DateFormat('dd-MM-yyyy').format(_selectedDate),
            inAccounts: inAccounts,
            outAccounts: outAccounts,
            time: "AM",
            openTime: _selectedDate.copyWith(hour: _selectedAMOpenTime.hour, minute: _selectedAMOpenTime.minute).millisecondsSinceEpoch,
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
      Toasts.showErrorMessageToast("Failed to create AM Match: $error");
    });

    showLoadingDialog(context: context, title: "Create PM Match", content: "creating...");
    FirebaseFirestore.instance
        .collection(Collections.match)
        .doc("${DateFormat('dd-MM-yyyy').format(_selectedDate)} PM")
        .set(DigitMatch(
            date: DateFormat('dd-MM-yyyy').format(_selectedDate),
            inAccounts: inAccounts,
            outAccounts: outAccounts,
            time: "PM",
            openTime: _selectedDate.copyWith(hour: _selectedPMOpenTime.hour, minute: _selectedPMOpenTime.minute).millisecondsSinceEpoch,
            closeTime: _selectedDate.copyWith(hour: _selectedPMCloseTime.hour, minute: _selectedPMCloseTime.minute).millisecondsSinceEpoch,
            isActive: false,
            createdDate: DateTime.now().millisecondsSinceEpoch,
            breakAmount: int.parse(pmBreakAmountController.text.toString()),
            digitPermission: []).toJson())
        .then((value) {
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Created PM Match Successfully");
    }).catchError((error) {
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Failed to create PM Match: $error");
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
    _selectedAMOpenTime = TimeOfDay.now().replacing(hour: 8, minute: 50);
    _selectedAMCloseTime = TimeOfDay.now().replacing(hour: 11, minute: 50);
    _selectedPMOpenTime = TimeOfDay.now().replacing(hour: 12, minute: 00);
    _selectedPMCloseTime = TimeOfDay.now().replacing(hour: 15, minute: 50);
    amBreakAmountController = TextEditingController();
    pmBreakAmountController = TextEditingController();

    amBreakAmountController.text = "35000";
    pmBreakAmountController.text = "35000";
  }

  @override
  void dispose() {
    super.dispose();
    amBreakAmountController.dispose();
    pmBreakAmountController.dispose();
  }
}
