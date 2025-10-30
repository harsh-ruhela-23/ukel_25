import 'package:flutter/material.dart';

class ColorManager {
  static Color primary = HexColor.fromHex("#131835");
  static Color darkGrey = HexColor.fromHex("#525252");
  static Color grey = HexColor.fromHex("#737477");
  static Color lightGrey = HexColor.fromHex("#9E9E9E");
  static Color primaryOpacity70 = HexColor.fromHex("#B33cb4b4");

  static Color darkPrimary = HexColor.fromHex("#131835");
  static Color grey1 = HexColor.fromHex("#707070");
  static Color grey2 = HexColor.fromHex("#797979");
  static Color white = HexColor.fromHex("#FFFFFF");
  static Color black = HexColor.fromHex("#000000");
  static Color error = HexColor.fromHex("#e61f34");

  //App colors
  static Color colorDarkBlue = HexColor.fromHex("#131835");
  static Color colorBlack = HexColor.fromHex("#1E1E1E");
  static Color colorLightGrey = HexColor.fromHex("#E4E5E9");
  static Color colorGrey = HexColor.fromHex("#A6A6A6");
  static Color colorDisable = HexColor.fromHex("#D9D9D9");
  static Color colorRed = HexColor.fromHex("#EF334C");
  static Color colorLightWhite = HexColor.fromHex("#F4F7FF");
  static Color colorBlue = HexColor.fromHex("#3C37FF");
  static Color colorGreen = HexColor.fromHex("#79CB9D");

  //Text colors
  static Color textColorBlack = HexColor.fromHex("#1E1E1E");
  static Color textColorWhite = HexColor.fromHex("#FFFFFF");
  static Color textColorGrey = HexColor.fromHex("#A6A6A6");
  static Color textColorRed = HexColor.fromHex("#EF334C");

  //Button colors
  static Color btnColorDarkBlue = HexColor.fromHex("#131835");
  static Color btnColorWhite = HexColor.fromHex("#FFFFFF");

  // francisCard Color
  static Color colorFrancisYellow = HexColor.fromHex("#FFD759");
  static Color colorFrancisCyan = HexColor.fromHex("#63D2FD");
  static Color colorFrancisLightPink = HexColor.fromHex("#FE6776");
  static Color colorFrancisPurple = HexColor.fromHex("#FE6776");
  static Color colorFrancisLightGreen = HexColor.fromHex("#79CB9D");
  static Color btnColorRed = HexColor.fromHex("#EE334B");

  //jobStatus Color
  static Color colorStatusPending = HexColor.fromHex("#EF334C");
  static Color colorStatusInShop = HexColor.fromHex("#FFD759");
  static Color colorStatusInProgress = HexColor.fromHex("#63D2FD");
  static Color colorStatusPickUp = HexColor.fromHex("#A3B0C3");
  static Color colorStatusQT = HexColor.fromHex("#877EFD");
  static Color colorStatusDeliver = HexColor.fromHex("#79CB9D");
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = 'FF' + hexColorString; // 8 Char with opacity 100%
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
