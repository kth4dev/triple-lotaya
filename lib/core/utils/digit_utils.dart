import 'package:lotaya/core/values/constants.dart';

class DigitUtils {
  static List<String> generateRValues(List<int> inputs) {
    if (inputs.length == 3) {
      int first = inputs[0];
      int second = inputs[1];
      int third = inputs[2];
      final originalList = [
        "$first$second$third",
        "$first$third$second",
        "$second$first$third",
        "$second$third$first",
        "$third$first$second",
        "$third$second$first",
      ];
      return originalList.toSet().toList();
    }
    return [];
  }

  static List<int> convertToListOfDigits(String numberStr) {
    List<int> digits = numberStr.split('').map((char) => int.parse(char)).toList();
    return digits;
  }

  static String getTwitSmaller(int win){
    if(win == 0){
      return '999';
    }else{
      return digitString(win-1);
    }

  }

  static String getTwitBigger(int win){
    if(win == 999){
      return '000';
    }
    return digitString(win+1);
  }

}
