import 'dart:convert';
import 'dart:math';

import '../services/get_storage.dart';
import 'constants.dart';

String generateRandomId() {
  final random = Random.secure();
  final values = List<int>.generate(25, (i) => random.nextInt(255));
  String generatedId = base64UrlEncode(values);
  return generatedId.substring(0, generatedId.length - 2);
}

String generateServiceInvoiceQRId() {
  // old
  // String characters = 'S';
  // String firstLetter = characters[Random().nextInt(characters.length)];
  // String lastFourDigits = Random().nextInt(10000).toString().padLeft(4, '0');
  // String qrCodeData = firstLetter + lastFourDigits;

  // NEW - with Branch code
  String characters = Storage.getValue(FbConstant.branchCode) ?? 'S';
  String lastFourDigits = Random().nextInt(10000).toString().padLeft(4, '0');
  String qrCodeData = characters.trim() + lastFourDigits.trim();
  return qrCodeData;
}

String generateJobItemInvoiceQRId() {
  // String randomString = randomAlphaNumeric(4);
  // String firstCharacter = String.fromCharCode(randomAlpha(1).codeUnitAt(0));
  // String qrCodeData = '$firstCharacter$randomString';

  String characters = 'J';
  String firstLetter = characters[Random().nextInt(characters.length)];
  String lastFourDigits = Random().nextInt(10000).toString().padLeft(4, '0');
  String qrCodeData = firstLetter.trim() + lastFourDigits.trim();

  return qrCodeData;
}

String generateRandomQRCode() {
  String randomString = (Random().nextInt(90000) + 10000).toString();
  return randomString;
}

String generateBranchCodeByBranchName(String text) {
  //* Limiting val should not be gt input length
  final max = 3 < text.length ? 3 : text.length;
  //* Get short name
  final name = text.substring(0, max);
  return name.toUpperCase();
}
