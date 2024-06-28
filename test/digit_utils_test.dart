import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotaya/core/utils/digit_utils.dart';

void main() {
  test('R Value', () {
    List<String> expected = DigitUtils.generateRValues([1, 2, 3]);
    debugPrint(expected.toString());
    expect(expected.length, 6);
  });

  test('R Value Same Two', () {
    List<String> expected = DigitUtils.generateRValues([4, 4, 6]);
    debugPrint(expected.toString());
    expect(expected.length, 3);
  });

  test('R Value Same All', () {
    List<String> expected = DigitUtils.generateRValues([1, 1, 1]);
    debugPrint(expected.toString());
    expect(expected.length, 1);
  });

  test('int to list', () {
    List<int> expected = DigitUtils.convertToListOfDigits("123");
    debugPrint(expected.toString());
    expect(expected, [1,2,3]);
  });
}