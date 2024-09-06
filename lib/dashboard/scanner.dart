import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sutlej_club/dashboard/sell_product.dart';
import 'package:vibration/vibration.dart';



class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);


  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scannedData='';
  bool _isShowingPopup = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swiping from left to right (right direction)
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [

            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 0.75 * MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: 25,
              left: 5,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleFlash,
                    icon: Icon(Icons.flash_on, color: Color(0xff124076)),
                    label: Text('Toggle Flash',style: TextStyle(color: Color(0xff124076)),),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!_isShowingPopup) {
        setState(() {
          scannedData = scanData.code ?? "";
          _isShowingPopup = true;
        });

        // Navigate to SellProduct page with scannedData as argument
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellProduct(phoneNumber: scannedData),
          ),
        );

        // Vibrate when QR code is successfully scanned
        Vibration.vibrate(duration: 500);
      }
    });
  }

  void _toggleFlash() {
    controller.toggleFlash();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}



// Color(0xff124076)  DARK BLUE
// Color(0xff596FB7) LIGHT BLUE