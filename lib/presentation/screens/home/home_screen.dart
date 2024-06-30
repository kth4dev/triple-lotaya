import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/routes/routes.dart';
import 'package:lotaya/core/styles/buttons/primary_button.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/core/values/images.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/presentation/bloc/check_new_version/check_new_version_bloc.dart';
import 'package:lotaya/presentation/screens/accounts/accounts_screen.dart';
import 'package:lotaya/presentation/screens/break/break_amount_screen.dart';
import 'package:lotaya/presentation/screens/digit_permission/digit_permission_screen.dart';
import 'package:lotaya/presentation/screens/digits/digit_screen.dart';
import 'package:lotaya/presentation/screens/hot_number/hot_number_screen.dart';
import 'package:lotaya/presentation/screens/list/list_screen.dart';
import 'package:lotaya/presentation/screens/login/login_screen.dart';
import 'package:lotaya/presentation/screens/match/match_screen.dart';
import 'package:lotaya/presentation/screens/notice_message/notice_message_screen.dart';
import 'package:lotaya/presentation/screens/person_sale/person_sale_list_screen.dart';
import 'package:lotaya/presentation/screens/sales/sales_screen.dart';
import 'package:lotaya/presentation/screens/slips/slips_screen.dart';
import 'package:lotaya/presentation/screens/win_number/win_number_screen.dart';
import '../../../core/styles/appbars/appbar.dart';
import '../user_digit/user_digit_screen.dart';
import 'widget/home_menu_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> listHomeMenu=[];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "LOTAYA-3D"),
      body: BlocListener<CheckNewVersionBloc, CheckNewVersionState>(
        listener: (context, state) {
          if(state is UpdateNewVersionState){
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                child:  AlertDialog(
                  title: const DefaultText("New Version Available", style: TextStyles.titleTextStyle),
                  content:const  DefaultText("Please update a new version...", style: TextStyles.bodyTextStyle),
                ),
                onWillPop: () async {
                  return false;
                },
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, childAspectRatio: 1.2, crossAxisSpacing: 5, mainAxisSpacing: 5),
                  padding: const EdgeInsets.all(8),
                  children:listHomeMenu ),
            ),
          ],
        ),
      ),
    );
  }

  int _getHomeMenuCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 900) {
      return 6;
    } else if (width > 600) {
      return 3;
    } else {
      return 2;
    }
  }

  double _spacing(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1300) {
      return 15;
    } else {
      return 5;
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CheckNewVersionBloc>(context).add(CheckVersionCode());
    listHomeMenu = (CacheHelper.getAccountInfo().type == "admin")
        ? [
      const HomeMenuWidget(
        label: "အရောင်း",
        image: Images.iconSales,
        nextPage: SalesScreen(),
        color: Colors.green,
      ),
      const HomeMenuWidget(
        label: "စလစ်",
        image: Images.iconReceipt,
        nextPage: SlipsScreen(),
        color: Colors.blue,
      ),
      const HomeMenuWidget(
        label: "စာရင်း",
        image: Images.iconAccounting,
        nextPage: ListScreen(),
        color: Colors.amber,
      ),
      const HomeMenuWidget(
        label: "ပေါက်သီး",
        image: Images.iconLotteryNumber,
        nextPage: WinNumberScreen(),
        color: Colors.teal,
      ),
      const HomeMenuWidget(
        label: "လယ်ဂျာ",
        image: Images.iconUserDigit,
        nextPage: UserDigitScreen(),
        color: Color(0xffa28809),
      ),
      const HomeMenuWidget(
        label: "ထိုးဂဏန်းများ",
        image: Images.iconNumbers,
        nextPage: DigitsScreen(),
        color: Colors.lightGreen,
      ),
      const HomeMenuWidget(
        label: "ကာစီး",
        image: Images.iconBreakAmount,
        nextPage: BreakAmountScreen(),
        color: Colors.brown,
      ),
      const HomeMenuWidget(
        label: "ဟော့ဂဏန်း",
        image: Images.iconHotNumber,
        nextPage: HotNumberScreen(),
        color: Colors.redAccent,
      ),
      const HomeMenuWidget(
        label: "အသိပေးစာ",
        image: Images.iconMessage,
        nextPage: NoticeMessageScreen(),
        color: Colors.blueGrey,
      ),
      const HomeMenuWidget(
        label: "ထိုးကြေးကန့်သတ်ချက်",
        image: Images.iconDigitPermission,
        nextPage: DigitPermissionScreen(),
        color: Colors.pink,
      ),
      const HomeMenuWidget(
        label: "ပွဲစဉ်ဇယား",
        image: Images.iconMatches,
        nextPage: MatchScreen(),
        color: Colors.purple,
      ),
      const HomeMenuWidget(
        label: "အကောင့်များ",
        image: Images.iconProfiles,
        nextPage: AccountScreen(),
        color: Colors.cyan,
      ),
    ]
        : [
      const HomeMenuWidget(
        label: "အရောင်း",
        image: Images.iconSales,
        nextPage: SalesScreen(),
        color: Colors.green,
      ),
      const HomeMenuWidget(
        label: "စလစ်",
        image: Images.iconReceipt,
        nextPage: SlipsScreen(),
        color: Colors.blue,
      ),
      const HomeMenuWidget(
        label: "စာရင်း",
        image: Images.iconAccounting,
        nextPage: ListScreen(),
        color: Colors.amber,
      ),
    ];
  }
}
