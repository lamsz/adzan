import 'package:flutter/material.dart';

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

class _AdzanPageState extends State<AdzanPage> {
  String locationError;
  PrayerTimes prayerTimes;
  var locationText = '';
  final latitudeController = TextEditingController();
  final locationController = TextEditingController();
  final longitudeController = TextEditingController();
  var latitude = '-6.7';
  var longitude = '107.5';
  var location = 'Banguntapan, Bantul';
  var switchValue = <bool>[];
  var switchAll = false;
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

  @override
  void initState() {
    super.initState();
    var params = CalculationMethod.singapore.getParameters();
    prayerTimes = PrayerTimes(
      Coordinates(double.parse(latitude), double.parse(longitude)),
      DateComponents.from(DateTime.now()),
      params,
    );
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

    var todayDateString = '${formatter.format(curTime)}';
    Timer(Duration(seconds: 1), () {
      curTime = DateTime.now();
      var nextPrayerTime = prayerTimes.timeForPrayer(prayerTimes.nextPrayer());
      if (nextPrayerTime != null) {
        var milisDiff = nextPrayerTime.millisecondsSinceEpoch -
            curTime.millisecondsSinceEpoch;
        var hourDiff = milisDiff ~/ 3600000;
        var minuteDiff = (milisDiff - hourDiff * 3600000) ~/ 60000;
        var secondDiff =
            (milisDiff - (hourDiff * 3600000) - (minuteDiff * 60000)) ~/ 1000;
        setState(() {
          textAdzanRemaining =
              'Next Prayer in $hourDiff hours $minuteDiff minutes  $secondDiff  seconds';
          locationText =
              '$location, ${curTime.hour.toString().padLeft(2, "0")}:${curTime.minute.toString().padLeft(2, "0")}:${curTime.second.toString().padLeft(2, "0")}  WIB';
        });
      } else {
        setState(() {
          textAdzanRemaining = 'Menunggu tengah malam';
        });
      }
    });
    Prayer.values.asMap().forEach((index, element) {
      if (index == 0) {
        element = Prayer.fajr;
      }
      switchValue.add(false);
      var sholatTime = prayerTimes.timeForPrayer(element);
      childWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: Container(
          height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        height: 40,
                        color: Colors.white.withOpacity(0.7),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(todayDateString, style: textTheme.subtitle1),
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
                          prayTimes[prayerTimes.nextPrayer().index].name,
                          style: textTheme.headline1,
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
}

class PrayerTimeWrapper {
  final String name;
  final bool reminderAble;

  PrayerTimeWrapper({this.name, this.reminderAble});
}
