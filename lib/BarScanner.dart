import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/style.dart';
import 'package:flutter_app/pages/SearchBarPopUpPage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:flutter_app/helpers/ListItemHelper.dart';

class BarScanner extends StatefulWidget {
  const BarScanner({Key? key}) : super(key: key);

  @override
  State<BarScanner> createState() => _BarScannerState();
}

class _BarScannerState extends State<BarScanner> {
  String CodeScan = 'None';
  @override
  void initState() {
    super.initState();
  }

  Future<void> startStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'failed to get platform version';
    }
    if (!mounted) return;

    setState(() {
      CodeScan = barcodeScanRes;
    });
  }

  Future ScanNormal() async {
    String BarScanN;
    try {
      BarScanN = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      String BarScan = BarScanN;
      print(BarScanN);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchMe(barcode: BarScan)));
    } on PlatformException {
      BarScanN = 'Failed to get platform version';
    }

    if (!mounted) return;

    setState(() {
      CodeScan = BarScanN;
      String Code = CodeScan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(backgroundColor: ColorConstant.teal300);
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: const Text('Barcode Scan Util'),
                backgroundColor: ColorConstant.teal300),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () => ScanNormal(),
                            child: const Text('Start Barcode Scan'),
                            style: style),
                        ElevatedButton(
                            onPressed: () => startStream(),
                            child: const Text('Start Barcode Stream'),
                            style: style),
                        Text('Scan Result: $CodeScan\n',
                            style: const TextStyle(fontSize: 20)),
                      ]));
            })));
  }
}

class SearchMe extends SearchBarPopUpPage {
  final String barcode;

  SearchMe({required this.barcode});

  Future<Product?> getProduct(String barcode) async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.ENGLISH,
      fields: [ProductField.ALL],
      version: ProductQueryVersion.v3,
    );
    final ProductResultV3 result =
        await OpenFoodAPIClient.getProductV3(configuration);

    if (result.status == ProductResultV3.statusSuccess &&
        result.product != null) {
      return result.product;
    } else {
      throw Exception('product not found, please insert data for $barcode');
    }
  }
}
