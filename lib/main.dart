import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/presentation/bloc/account/account_bloc.dart';
import 'package:lotaya/presentation/bloc/check_new_version/check_new_version_bloc.dart';
import 'package:lotaya/presentation/bloc/list/list_bloc.dart';
import 'package:lotaya/presentation/bloc/matche/match_bloc.dart';
import 'package:lotaya/presentation/bloc/receipt/receipt_list_bloc.dart';
import 'package:lotaya/presentation/bloc/slip_id/slip_id_bloc.dart';
import 'package:lotaya/presentation/bloc/user_digits/user_digits_bloc.dart';
import 'package:lotaya/presentation/bloc/win_number/win__number_bloc.dart';
import 'package:lotaya/presentation/screens/home/home_screen.dart';
import 'package:lotaya/presentation/screens/login/login_screen.dart';
import 'package:oktoast/oktoast.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await CacheHelper.ensureInitialized();

  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (create) => CheckNewVersionBloc()),
        BlocProvider(create: (create) => AccountBloc()),
        BlocProvider(create: (create) => ReceiptListBloc()),
        BlocProvider(create: (create) => SlipIdBloc()),
        BlocProvider(create: (create) => MatchBloc()),
        BlocProvider(create: (create) => WinNumberBloc()),
        BlocProvider(create: (create) => ListBloc()),
        BlocProvider(create: (create) => UserDigitsBloc()),
      ],
      child: OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lotaya 3D',
          scrollBehavior: MyCustomScrollBehavior(),
          theme: ThemeData(
              useMaterial3: false,
              primarySwatch: Colors.green,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white)),
          home: (CacheHelper.getData(key: "account_info") != null)
              ? const HomeScreen()
              : const LoginScreen(),
        ),
      ),
    );
  }
}
