import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dice_icons/dice_icons.dart';
import 'package:flutter/services.dart';
import 'package:fluttertest/custom_icons_icons.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertest/my_flutter_app_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

var curIndex = 0;
var page = 0;

enum CurWidget { home, status }

CurWidget currentWidget = CurWidget.home;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String buttonName = "test";

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MainWidget extends StatefulWidget {
  final BluetoothDevice? device;
  const MainWidget({super.key, required this.device});

  @override
  State<StatefulWidget> createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  var initiative = 0;
  BluetoothDevice? connection;
  BluetoothService? service;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      connection = widget.device;
    });

    connection?.connectionState.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.connected) {
        print('Connected to the device!');
        // Proceed with discovering services
      } else if (state == BluetoothConnectionState.disconnected) {
        isConnected = false;
        print('Disconnected from the device!');
        connect();
      }
    });

    if (connection != null) {
      connect();
    }
  }

  Future<String> getBluetoothPref() async {
    final prefs = await SharedPreferences.getInstance();
    final blstr = await prefs.getString("blstr");
    if (blstr == null) {
      return "";
    } else {
      return blstr;
    }
  }

  Future<void> connect() async {
    try {
      await connection?.connect();

      List<BluetoothService>? services = await connection?.discoverServices();
      setState(() {
        isConnected = true;
        service = services?.last;
      });
      BluetoothCharacteristic? characteristic = service?.characteristics.last;
      List<int> list;
      if (curIndex == 0) {
        list = utf8.encode("p");
      } else {
        list = utf8.encode("y");
      }

      Uint8List bytes = Uint8List.fromList(list);
      await characteristic?.write(bytes);
      print("Success");
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
      } else {
        print(e);
      }
    }
  }

  Future<void> handlePress() async {
    if (currentWidget == CurWidget.home) {
      setState(() {
        curIndex = Random().nextInt(2);
      });
      if (isConnected) {
        BluetoothCharacteristic? characteristic = service?.characteristics.last;
        List<int> list;
        if (curIndex == 0) {
          list = utf8.encode("p");
        } else {
          list = utf8.encode("y");
        }

        Uint8List bytes = Uint8List.fromList(list);
        await characteristic?.write(bytes);
      }
    } else {
      setState(() {
        initiative = Random().nextInt(20) + 1;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: Colors.transparent,
                content: Center(
                  child: Text(
                    initiative.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                elevation: 24.0,
              ),
          barrierDismissible: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: curIndex == 0
            ? const Text(
                "Darcia",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "MedievalSharp",
                    fontSize: 30),
              )
            : const Text(
                "Lucia",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "MedievalSharp",
                    fontSize: 30),
              ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const SettingsWidget();
              }));
            },
            icon: const Icon(Icons.settings)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          elevation: 0.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    page = 0;
                    currentWidget = CurWidget.home;
                  });
                },
                icon: Icon(
                  Icons.home,
                  color: page == 1
                      ? const Color.fromARGB(255, 107, 106, 106)
                      : curIndex == 0
                          ? Colors.purple[300]
                          : const Color.fromARGB(255, 230, 211, 47),
                ),
              ),
              const SizedBox(height: 1),
              IconButton(
                onPressed: () {
                  setState(() {
                    page = 1;
                    currentWidget = CurWidget.status;
                  });
                },
                icon: Icon(
                  DiceIcons.dice6,
                  color: page == 0
                      ? const Color.fromARGB(255, 107, 106, 106)
                      : curIndex == 0
                          ? Colors.purple[300]
                          : const Color.fromARGB(255, 230, 211, 47),
                ),
              )
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
          backgroundColor:
              curIndex == 0 ? Colors.purple[400] : Colors.amber[300],
          onPressed: handlePress,
          child: AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            duration: const Duration(milliseconds: 500),
            child: currentWidget == CurWidget.status
                ? const Icon(
                    CustomIcons.broadsword,
                    color: Colors.white,
                    key: Key('1'),
                  )
                : const Icon(Icons.auto_awesome_sharp,
                    color: Colors.white, key: Key('2')),
          )),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({super.key});

  @override
  State<StatefulWidget> createState() => BodyWidgetState();
}

class BodyWidgetState extends State<BodyWidget> {
  int hp = 0;

  Future<int> getHP() async {
    final prefs = await SharedPreferences.getInstance();
    final hp = prefs.getInt("HitPoints");
    if (hp == null) {
      return 84;
    } else {
      print(hp.toString());
      return hp;
    }
  }

  void initState() {
    super.initState();
    set();
  }

  Future<void> set() async {
    hp = await getHP();
  }

  Future<int> setHP(String value) async {
    int ret = 0;
    try {
      var valueInt = int.parse(value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("HitPoints", valueInt);
    } on FormatException {
      ret = 1;
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: curIndex == 0
                ? const AssetImage('assets/images/purple5.jpg')
                : const AssetImage('assets/images/yellow1.jpg'),
            fit: BoxFit.cover),
      ),
      child: getCustomWidget(),
    );
  }

  Widget getCustomWidget() {
    if (currentWidget == CurWidget.home) {
      return getHomeWidget();
    } else {
      return getStatusWidget();
    }
  }

  Widget getHomeWidget() {
    return const Center(
      child: Text(
        "Home",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget getStatusWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.sizeOf(context).height * 0.10,
          width: MediaQuery.sizeOf(context).width * 0.95,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("18",
                        style: TextStyle(
                            fontFamily: "Cinzel",
                            color: Colors.white,
                            fontSize: 20)),
                  ),
                  const Text("Armor Class",
                      style: TextStyle(
                          fontFamily: "RobotoSlab",
                          color: Colors.white,
                          fontSize: 12)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(hp.toString(),
                        style: const TextStyle(
                            fontFamily: "Cinzel",
                            color: Colors.white,
                            fontSize: 20)),
                  ),
                  const Text("Hit Points",
                      style: TextStyle(
                          fontFamily: "RobotoSlab",
                          color: Colors.white,
                          fontSize: 12)),
                ],
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {},
                      child: const Text("2",
                          style: TextStyle(
                              fontFamily: "Cinzel",
                              color: Colors.white,
                              fontSize: 20)),
                    ),
                    const Text("Initiative",
                        style: TextStyle(
                            fontFamily: "RobotoSlab",
                            color: Colors.white,
                            fontSize: 12))
                  ]),
            ],
          ),
        ),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.6,
          width: MediaQuery.sizeOf(context).width * 0.95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.sizeOf(context).height * 0.55,
                width: MediaQuery.sizeOf(context).width * 0.6,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 4),
                    borderRadius: BorderRadius.circular(10)),
                child: const Column(children: <Widget>[]),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.55,
                width: MediaQuery.sizeOf(context).width * 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.sizeOf(context).width * 0.25,
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(MyFlutterApp.touch_app,
                                  color: Colors.white),
                            ),
                            const Text("Chill Touch",
                                style: TextStyle(
                                    fontFamily: "RobotoSlab",
                                    color: Colors.white,
                                    fontSize: 12))
                          ]),
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).width * 0.25,
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(MyFlutterApp.touch_app,
                                  color: Colors.white),
                            ),
                            const Text("Chill Touch",
                                style: TextStyle(
                                    fontFamily: "RobotoSlab",
                                    color: Colors.white,
                                    fontSize: 12))
                          ]),
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).width * 0.25,
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(MyFlutterApp.touch_app,
                                  color: Colors.white),
                            ),
                            const Text("Chill Touch",
                                style: TextStyle(
                                    fontFamily: "RobotoSlab",
                                    color: Colors.white,
                                    fontSize: 12))
                          ]),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<StatefulWidget> createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  List<BluetoothDevice> systemDevices = [];
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  bool isPressed = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      print(e);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();
  }

  Future onScanPressed() async {
    if (!isPressed) {
      try {
        systemDevices = await FlutterBluePlus.systemDevices;
      } catch (e) {
        print(e);
      }
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      } catch (e) {
        print(e);
      }
      if (mounted) {
        setState(() {});
      }
      isPressed = !isPressed;
    } else {
      try {
        FlutterBluePlus.stopScan();
      } catch (e) {
        print(e);
      }
      isPressed = !isPressed;
    }
  }

  Future onConnectPressed(BluetoothDevice data) async {
    try {
      print("aaaaaaaaaaaaaaaaaaaa");
      await FlutterBluePlus.stopScan();
      await data.connect(mtu: null);
      print("Success");
      await data.disconnect();
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainWidget(device: data)));
      }
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        print("bbbbbbbbbbbbbbbbbbbb");
      } else {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: curIndex == 0
                  ? const AssetImage('assets/images/purple5.jpg')
                  : const AssetImage('assets/images/yellow1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: onScanPressed, child: const Text("press me")),
              Text(scanResults.length.toString()),
              ListView.builder(
                shrinkWrap: true,
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final data = scanResults[index].device;
                  if (data.advName == "ESP32") {
                    return Card(
                        child: ListTile(
                      title: Text(data.advName),
                      subtitle: Text(data.remoteId.toString()),
                      onTap: () {
                        onConnectPressed(data);
                      },
                    ));
                  }
                },
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const MainWidget(
                device: null,
              )));
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.purple, Colors.yellow],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CustomIcons.dragon, color: Colors.white, size: 40),
            Text("The Bridge",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
