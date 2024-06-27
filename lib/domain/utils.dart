import 'package:lotaya/data/model/user.dart';

import '../data/cache/cache_helper.dart';

bool isAccountContain(Account account){
  if (account.name == CacheHelper.getAccountInfo().name || account.referUser == CacheHelper.getAccountInfo().name || CacheHelper.getAccountInfo().type=="admin"){
    return true;
  }else{
    return false;
  }
}