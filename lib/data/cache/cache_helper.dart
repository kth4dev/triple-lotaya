import 'dart:convert';


import 'package:lotaya/data/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _sharedPreferences;

  static Future<void> ensureInitialized() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  static dynamic getData({required String key}) {
    return _sharedPreferences?.get(key);
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await _sharedPreferences!.setString(key, value);
    if (value is double) return await _sharedPreferences!.setDouble(key, value);
    if (value is bool) return await _sharedPreferences!.setBool(key, value);
    if (value is List<String>) return await _sharedPreferences!.setStringList(key, value);
    await ensureInitialized();
    return await _sharedPreferences!.setInt(key, value);
  }

  static void removeData({required String key}) async {
    await ensureInitialized();
    await _sharedPreferences!.remove(key);
  }

  static void removeAllData() async {
    await ensureInitialized();
    await _sharedPreferences!.clear();
  }

  static Account getAccountInfo(){
    return Account.fromJson(json.decode(getData(key: "account_info")));
  }

  static Future<void> saveAccountInfo(Account account) async{
    await saveData(key: 'account_info',value: json.encode(account.toJson()));
  }

  static void removeLoginResponse() async{
    await ensureInitialized();
    await _sharedPreferences!.remove("account_info");
  }
}
