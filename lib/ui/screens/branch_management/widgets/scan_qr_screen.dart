import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/invoice/invoice_details_screen.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () => AppUtils.navigateUp(context),
          title: "Scan QR",
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListView(
                children: [
                  SizedBox(height: 20.sp),
                  if (result != null)
                    Center(
                      child: Text(
                        'Data: ${result!.code}',
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xff0FA931),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'Scanning...',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff0FA931),
                        ),
                      ),
                    ),
                  SizedBox(height: 40.sp),
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? SizedBox(height: 280, child: _buildQrView(context))
                      : SizedBox(
                          height: 200,
                          child: _buildQrView(context),
                        ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 25.sp, left: 20.sp, right: 20.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                              child:
                                  SvgPicture.asset(IconAssets.iconScanGallery),
                            ),
                            InkWell(
                              onTap: () async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              child: SvgPicture.asset(IconAssets.iconScanFlash),
                            )
                          ],
                        ),
                        SizedBox(height: 25.sp),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            'Scan QR Code To get information about Invoice',
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                              color: ColorManager.textColorGrey,
                              fontSize: 15.5.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 260.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return Stack(
      alignment: Alignment.center,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: ColorManager.primary,
              borderLength: 30,
              overlayColor: Colors.white,
              borderWidth: 12,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Lottie.asset(
          'assets/scanner_animation.json',
          // height: 50,
        )
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();

      if (scanData.code != null) {
        if (scanData.code!.contains('S')) {
          fetchServiceInvoiceByQRId(scanData.code!).then((model) {
            if (model != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceDetailsScreen(model: model),
                ),
              ).then((value) {
                controller.resumeCamera();
              });
            }
          });
        } else if (scanData.code!.contains('J')) {
          fetchJobItemByQRId(scanData.code!).then((model) {
            if (model != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobStatusScreen(jobItemModel: model),
                ),
              ).then((value) {
                controller.resumeCamera();
              });
            }
          });
        }
      }

      setState(() {
        result = scanData;
      });
    });
  }

  // fetch completed Job List
  Future<ServiceInvoiceModel?> fetchServiceInvoiceByQRId(String qrCode) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.serviceInvoice)
          .where(FbConstant.serviceInvoiceCode,
              isEqualTo: qrCode.replaceFirst("#", ""))
          .get();

      ServiceInvoiceModel? model;

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          model = ServiceInvoiceModel.fromJson(item.data());
        }
      }
      return model;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetch Job item
  Future<JobItemModel?> fetchJobItemByQRId(String qrCode) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .where(FbConstant.jobItemCode,
              isEqualTo: qrCode.replaceFirst("#", ""))
          .get();

      JobItemModel? model;

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          model = JobItemModel.fromJson(item.data());
        }
      }
      return model;
    } catch (e) {
      throw e.toString();
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
