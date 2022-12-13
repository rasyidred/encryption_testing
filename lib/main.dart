import 'package:flutter/material.dart';
import 'package:web3dart/crypto.dart';
import 'package:xor/xor.dart';
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

  void encrypt(String message, String secret) {
    // const source = 'Anjing';
    // const secret = 'ini key';

    // final sourceHex = StringToHex.toHexString(source);
    var messageHex = convertStringToUint8List(message);
    // var testSource = bytesToHex(messageHex);

    var secretHex = convertStringToUint8List(secret);
    // secretHex = keccak256(secretHex);

    // var testSecret = bytesToHex(secretHex);

    var encrypted = xor(messageHex, secretHex);
    var resultE = bytesToHex(encrypted);

    // var decrypted = xor(encrypted, secretHex);
    // var resultD = bytesToHex(decrypted);

    print('Encryption Result: $resultE\n'
        // 'Encrypted: $encrypted\n'
        // 'Key: $secretHex\n'
        // 'Decrypted: $decrypted\n'
        // 'ResultD: ${convertUint8ListToString(decrypted)}\n'
        // 'Identical: ${identical(source, decrypted)}',
        );
  }

  void decryptHash1(String encrypted, String key) {
    Uint8List encryptedHex = hexToBytes(encrypted);

    // var keyHex = convertStringToUint8List(key);
    // var keyHexx = bytesToHex(keyHex);
    var keyHex = hexToBytes(key);

    Uint8List resultDecrypt = xor(encryptedHex, keyHex);

    String resultDecryptString = bytesToHex(resultDecrypt);

    print(
      // 'Encrypted Hex: $encryptedHex\n'
      'Result Hasil Decrypt: $resultDecryptString\n'
      // 'KeyHex Decrypt: $keyHex',
      ,
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
                encrypt('Anjing', 'ini key');
                decryptHash1(
                    'b52381fcf8bab37c667cbb8a288cabafcfdacd75dbc17e0ee1f8990cc9ce4bcf',
                    '696e69206b6579');
              },
              child: Text('Pesan'),
            )
          ],
        ),
      ),
    );
  }
}
