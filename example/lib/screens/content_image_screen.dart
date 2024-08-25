import 'dart:io' as io;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webcontent_converter/webcontent_converter.dart';
import 'package:webcontent_converter_example/services/demo.dart';
// import 'package:webcontent_converter_example/services/webview_helper.dart';

class ContentToImageScreen extends StatefulWidget {
  @override
  _ContentToImageScreenState createState() => _ContentToImageScreenState();
}

class _ContentToImageScreenState extends State<ContentToImageScreen> {
  int _counter = 1;
  Uint8List? _bytes;
  io.File? _file;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Content to Image"),
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () {
              Future.forEach(List.generate(_counter, (index) => null).toList(),
                  (i) async {
                try {
                  await _convert();
                  await Future.delayed(Duration(seconds: 5));
                } catch (e) {
                  ///
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.wifi_rounded),
            onPressed: _startPrintWireless,
          ),
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: _startPrintBluetooth,
          ),
          IconButton(
              onPressed: () {
                if (scaffoldKey.currentState == null) return;
                scaffoldKey.currentState!.openEndDrawer();
              },
              icon: Icon(Icons.menu))
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("counter is $_counter"),
              subtitle: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _counter = 1;
                        });
                      },
                      icon: Icon(Icons.refresh)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _counter -= 1;
                        });
                      },
                      icon: Icon(Icons.remove)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _counter += 1;
                        });
                      },
                      icon: Icon(Icons.add)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            children: [
              if (_file != null)
                Container(
                  width: 400,
                  alignment: Alignment.topCenter,
                  child: Image.memory(_file!.readAsBytesSync()),
                ),
              Divider(),
              if (_bytes?.isNotEmpty == true)
                Container(
                  width: 400,
                  alignment: Alignment.topCenter,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blue)),
                  child: Image.memory(_bytes!),
                )
            ],
          ),
        ),
      ),
    );
  }

  ///[convert html] content into bytes
  _convert() async {
    var stopwatch = Stopwatch()..start();
    var bytes = await WebcontentConverter.contentToImage(
        content: _counter.isEven
            ? Demo.getShortReceiptContent()
            : Demo.getReceiptContent(),
        executablePath: WebViewHelper.executablePath(),
        args: {
          "is_html2bitmap": true,
          "bitmap_width": 300.0,
        });
    WebcontentConverter.logger
        .info("completed executed in ${stopwatch.elapsed}");
    setState(() => _counter += 1);
    if (bytes.isNotEmpty) {
      _saveFile(bytes);
      WebcontentConverter.logger.info("bytes.length ${bytes.length}");
    }
  }

  ///[save bytes] into file
  _saveFile(Uint8List bytes) async {
    setState(() => _bytes = bytes);
    if (kIsWeb) {
      return;
    }
    var dir = await getTemporaryDirectory();
    var path = join(dir.path, "receipt.jpg");
    io.File file = io.File(path);
    await file.writeAsBytes(bytes);
    WebcontentConverter.logger.info(file.path);
    setState(() => _file = file);
  }

  _startPrintWireless() async {
    // var p = ESCPrinterService(_bytes);
    // p.startPrint();
  }

  _startPrintBluetooth() {
    // var p = ESCPrinterService(_bytes);
    // p.startBluePrint();
  }
}
