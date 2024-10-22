import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Ensure you import this for XFile

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    return result.any((element) => element != ConnectivityResult.none);
  }

  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Check if any result indicates a connection
      bool isConnected = results.any((result) =>
      result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);

      if (Get.find<SplashController>().firstTimeConnectionCheck) {
        Get.find<SplashController>().setFirstTimeConnectionCheck(false);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }

  static Future<XFile> compressImage(XFile file) async {
    final ImageFile input = ImageFile(filePath: file.path, rawBytes: await file.readAsBytes());
    final Configuration config = Configuration(
      outputType: ImageOutputType.webpThenPng,
      useJpgPngNativeCompressor: false,
      quality: (input.sizeInBytes / 1048576) < 2
          ? 90
          : (input.sizeInBytes / 1048576) < 5
          ? 50
          : (input.sizeInBytes / 1048576) < 10
          ? 10
          : 1,
    );
    final ImageFile output = await compressor.compress(ImageFileConfiguration(input: input, config: config));
    if (kDebugMode) {
      print('Input size : ${input.sizeInBytes / 1048576}');
      print('Output size : ${output.sizeInBytes / 1048576}');
    }
    return XFile.fromData(output.rawBytes);
  }
}
