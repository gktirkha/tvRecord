import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[0], ResolutionPreset.max,
          enableAudio: true);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              // Handle access errors here.
              break;
            default:
              // Handle other errors here.
              break;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((controller == null) ||
        (!controller!.value.isInitialized) ||
        _cameras.isEmpty) {
      log("message");
      return MaterialApp(home: Scaffold(body: Container()));
    }
    return MaterialApp(
      home: Stack(
        children: [
          CameraPreview(controller!),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      await controller!.startVideoRecording();
                    },
                    icon: const Icon(Icons.record_voice_over_rounded),
                  ),
                  IconButton(
                    onPressed: () async {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.storage,
                      ].request();

                      if (statuses[Permission.storage]!.isGranted) {
                        var path = "/storage/emulated/0/Download";

                        log(path);

                        await (await controller!.stopVideoRecording()).saveTo(
                            "$path/${DateFormat("ddMMhhmmss").format(DateTime.now().toLocal())}.mp4");
                      }
                    },
                    icon: const Icon(Icons.stop),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
