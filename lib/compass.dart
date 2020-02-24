import 'dart:math' as math;
import 'dart:ui';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:richtung/home_location.dart';

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

  double get tangentAngle => (tangent?.angle ?? math.pi / 2) - math.pi / 2;

  @override
  void initState() {
    _fetchPermissionStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(tangentAngle);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: (_hasPermissions)
            ? StreamBuilder<Object>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  direction = snapshot.data;
                  // print(direction);
                  // print(tangentAngle);
                  return Transform.rotate(
                    angle: ((direction ?? 0) * (math.pi / 180) * -1) -
                        tangentAngle,
                    child: Image.asset('assets/images/test.jpg'),
                  );
                },
              )
            : Center(
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
      ),
    );
  }

  void _fetchPermissionStatus() {
    permission.PermissionHandler()
        .checkPermissionStatus(permission.PermissionGroup.locationWhenInUse)
        .then((status) {
      // print(status);
      if (mounted) {
        // print(mounted);
        _fetchCurrentLocation();
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
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _location = Location();
    _fetchCurrentLocation();
    _location.onLocationChanged().listen((LocationData currentLocation) {
      _fetchCurrentLocation();
      setState(() {});
    });
  }
}
