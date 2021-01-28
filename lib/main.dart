import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:location/location.dart';
import 'package:mapbox_geocoding/mapbox_geocoding.dart';
import 'package:mapbox_geocoding/model/reverse_geocoding.dart';

void main() {
  runApp(Adzan());
}

class Adzan extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        return MaterialApp(
          title: 'Adzan Reminder',
          home: AdzanPage(title: 'Jadwal Sholat'),
          debugShowCheckedModeBanner: false,
        );
      });
    });
  }
}

class AdzanPage extends StatefulWidget {
  AdzanPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdzanPageState createState() => _AdzanPageState();
}

const apikey = String.fromEnvironment('apikey');

class _AdzanPageState extends State<AdzanPage> {
  String locationError;
  PrayerTimes prayerTimes;
  var timeText = '';
  final latitudeController = TextEditingController();
  final locationController = TextEditingController();
  final longitudeController = TextEditingController();
  var latitude = -7.840243;
  var longitude = 110.408333;
  var switchValue = <bool>[];
  var switchAll = false;
  var address = '';
  MapboxGeocoding geocoding = MapboxGeocoding(apikey);
  // name in local
  var prayTimes = [
    PrayerTimeWrapper(name: 'Imsak', reminderAble: false),
    PrayerTimeWrapper(name: 'Shubuh', reminderAble: true),
    PrayerTimeWrapper(name: 'Fajar', reminderAble: true),
    PrayerTimeWrapper(name: 'Dzuhur', reminderAble: true),
    PrayerTimeWrapper(name: 'Ashar', reminderAble: true),
    PrayerTimeWrapper(name: 'Maghrib', reminderAble: true),
    PrayerTimeWrapper(name: 'Isya', reminderAble: true),
  ];

  var curTime = DateTime.now();

  var textAdzanRemaining = '';
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  @override
  void initState() {
    super.initState();
    setPrayer(latitude, longitude);
    _askCurrentLocation();
    // var nextPrayerTime = prayerTimes.timeForPrayer(prayerTimes.nextPrayer());
    initializeDateFormatting('id', null);
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var childWidgets = <Widget>[];

    var jadwalBar = AppBar(
      title: Text(
        widget.title,
        style: textTheme.headline3.copyWith(color: Colors.white),
      ),
    );

    final DateFormat formatter = DateFormat('EEEE d MMMM y', 'id');

    // var todayDateString = '$locationText,  }';
    Timer(Duration(seconds: 1), () {
      if (prayerTimes != null) {
        curTime = DateTime.now();
        var nextPrayerTime =
            prayerTimes.timeForPrayer(prayerTimes.nextPrayer());
        if (nextPrayerTime != null) {
          var milisDiff = nextPrayerTime.millisecondsSinceEpoch -
              curTime.millisecondsSinceEpoch;
          var hourDiff = milisDiff ~/ 3600000;
          var minuteDiff = (milisDiff - hourDiff * 3600000) ~/ 60000;
          var secondDiff =
              (milisDiff - (hourDiff * 3600000) - (minuteDiff * 60000)) ~/ 1000;
          setState(() {
            textAdzanRemaining =
                'tinggal $hourDiff jam $minuteDiff menit $secondDiff detik lagi';
            timeText =
                '${formatter.format(curTime)} ${curTime.hour.toString().padLeft(2, "0")}:${curTime.minute.toString().padLeft(2, "0")}:${curTime.second.toString().padLeft(2, "0")}  GMT+7';
          });
        } else {
          setState(() {
            textAdzanRemaining = 'Menunggu tengah malam';
          });
        }
      }
    });
    Prayer.values.asMap().forEach((index, element) {
      if (index == 0) {
        element = Prayer.fajr;
      }
      switchValue.add(false);
      var sholatTime = prayerTimes.timeForPrayer(element);
      if (sholatTime != null && index == 0) {
        sholatTime = sholatTime.subtract(Duration(minutes: 10));
      }
      childWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: Container(
          height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 4,
                  child: Text(
                    prayTimes[index].name,
                    style: textTheme.subtitle1,
                  )),
              Expanded(
                flex: 2,
                child: Text(
                  '${sholatTime.hour.toString().padLeft(2, "0")}:${sholatTime.minute.toString().padLeft(2, "0")}',
                  style: textTheme.subtitle1,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ));
    });

    return Scaffold(
      appBar: jadwalBar,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height -
                50 -
                MediaQuery.of(context).padding.top -
                jadwalBar.preferredSize.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: double.maxFinite,
                        height: 80,
                        color: Colors.white.withOpacity(0.7),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    child: Text(
                                      address,
                                      style: textTheme.subtitle1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      timeText,
                                      style: textTheme.subtitle1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
                Spacer(),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          'Sholat berikutnya ',
                          style: textTheme.headline6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              prayTimes[prayerTimes.nextPrayer().index].name,
                              style: textTheme.headline1,
                            ),
                          ],
                        ),
                        Text(textAdzanRemaining, style: textTheme.subtitle1)
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10),
                    child: Container(
                        child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        padding: EdgeInsets.all(10),
                        height: MediaQuery.of(context).size.height / 2,
                        width: double.maxFinite,
                        child: Column(children: childWidgets),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  setPrayer(latitude, longitude) async {
    try {
      setState(() {
        var params = CalculationMethod.singapore.getParameters();
        prayerTimes = PrayerTimes(
          Coordinates(latitude, longitude),
          DateComponents.from(DateTime.now()),
          params,
        );
      });

      // final coordinates = new geocoder.Coordinates(latitude, longitude);
      // var addresses = await geocoder.Geocoder.local
      //     .findAddressesFromCoordinates(coordinates);
      // setLocation(latitude, longitude, addresses);
    } catch (ex) {
      print("Exception thrown : " + ex.toString());
    }
  }

  void setLocation(latitude, longitude, addresses) {
    setState(() {
      var first = addresses.first;
      timeText =
          '${first.featureName} : ${first.addressLine}, lat ${latitude.toString()} long ${longitude.toString()}';
    });
  }

  // ignore: unused_element
  Future<void> _askCurrentLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setCity(_locationData.latitude, _locationData.longitude);
  }

  void setCity(double latitude, double longitude) async {
    ///Reverse geocoding. Get place name from latitude and longitude.
    try {
      ReverseGeocoding reverseModel = await geocoding
          .reverseModel(latitude, longitude, limit: 10, types: 'locality');
      setState(() {
        address = reverseModel.features[0].placeName;
        // print(reverseModel.features.length);
      });
    } catch (Excepetion) {
      print('Reverse Geocoding Error');
    }
  }
}

class PrayerTimeWrapper {
  final String name;
  final bool reminderAble;

  PrayerTimeWrapper({this.name, this.reminderAble});
}
