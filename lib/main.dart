import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:xor_cipher/xor_cipher.dart';
import 'package:pointycastle/export.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:hex/hex.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  String convertUint8ListToString(Uint8List uint8list) {
    return String.fromCharCodes(uint8list);
  }

  void encrypt() {
    const source = 'Anjing';
    const secret = 'Top 😺 secret';

    // final sourceHex = StringToHex.toHexString(source);
    var sourceHex = convertStringToUint8List(source);
    var secretHex = convertStringToUint8List(secret);
    print(
      'Source: $source\n'
      'SourceHex: $sourceHex\n'
      'Secret: $secret'
      'SecretHex: $secretHex\n',
    );
    final encrypted = XOR.encrypt(sourceHex.toString(), secretHex.toString(),
        urlEncode: true);
    final decrypted = XOR.decrypt(encrypted, secret, urlDecode: true);

    // final encrypted = convertUint8ListToString(sourceHex);
    // final decrypted = convertUint8ListToString(secretHex);

    print(
      'Encrypted: $encrypted\n'
      'Decrypted: $decrypted\n'
      'Identical: ${identical(source, decrypted)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Ini App Bar'),
        ),
        body: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                encrypt();
              },
              child: Text('Pesan'),
            )
          ],
        ),
      ),
    );
  }
}
