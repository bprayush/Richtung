import 'dart:math' as math;
import 'dart:ui';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:richtung/home_location.dart';
import 'package:richtung/screen_size.dart';

class Compass extends StatefulWidget {
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> with AfterLayoutMixin {
  double direction = 0.0;
  bool _hasPermissions = false;
  Location _location;
  LocationData _currentLocation;
  Tangent tangent;
  final double compassWidth = ScreenSize.width / 1.2;
  final double needleWidth = ScreenSize.width / 2;

  double get tangentAngle => (tangent?.angle ?? math.pi / 2) - math.pi / 2;

  @override
  void initState() {
    _fetchPermissionStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(tangentAngle);
    ScreenUtil.init(
      context,
      width: ScreenSize.width,
      height: ScreenSize.height,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Container(
              width: ScreenUtil().setHeight(280),
              height: ScreenUtil().setHeight(280),
              decoration: BoxDecoration(
                // color: Colors.blue,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(
                    'assets/images/compass.png',
                  ),
                ),
              ),
            ),
          ),
          if (_hasPermissions)
            StreamBuilder<Object>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                direction = snapshot.data;
                return Align(
                  alignment: Alignment(ScreenUtil().setWidth(0.03), 0),
                  child: Transform.rotate(
                    angle: ((direction ?? 0) * (math.pi / 180) * -1) -
                        tangentAngle -
                        (math.pi / 4),
                    child: Container(
                      width: ScreenUtil().setWidth(100),
                      height: ScreenUtil().setWidth(100),
                      decoration: BoxDecoration(
                        // color: Colors.red,
                        image: DecorationImage(
                          image: AssetImage('assets/images/needle4.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _requestPermission();
                    },
                    child: Text('Grant location access.'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    permission.PermissionHandler()
        .checkPermissionStatus(permission.PermissionGroup.locationWhenInUse)
        .then((status) {
      // print(status);
      // print('fetching permissions done!');
      _fetchCurrentLocation();
      if (mounted) {
        // print(mounted);
        setState(
          () => _hasPermissions = status == permission.PermissionStatus.granted,
        );
      }
    });
  }

  void _requestPermission() {
    permission.PermissionHandler().requestPermissions(
        [permission.PermissionGroup.locationWhenInUse]).then((onValue) {
      _fetchPermissionStatus();
    });
  }

  void _fetchCurrentLocation() async {
    _currentLocation = await _location.getLocation();
    tangent = Tangent(
      Offset.zero,
      homeLocation -
          Offset(
            _currentLocation.latitude,
            _currentLocation.longitude,
          ),
    );
    // print('................... $tangent');
    setState(() {});
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _location = Location();
    _fetchCurrentLocation();
    _location.onLocationChanged().listen((LocationData currentLocation) {
      // print('Location changed!!!');
      _fetchCurrentLocation();
    });
  }
}
