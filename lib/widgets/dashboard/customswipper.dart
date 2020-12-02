import 'package:dcsmobile/charts/donutautolabelchart.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class CustomSwipper extends StatefulWidget {
  final MediaQueryData mediaQuery;
  final data;

  CustomSwipper({this.mediaQuery, this.data}) : super();

  @override
  _CustomSwipperState createState() =>
      _CustomSwipperState(this.mediaQuery, this.data);
}

class _CustomSwipperState extends State<CustomSwipper> {
  final MediaQueryData mediaQuery;
  final data;

  _CustomSwipperState(this.mediaQuery, this.data);

  double itemHeight;
  double itemWidth;
  double boxConstraints;

  @override
  void initState() {
    super.initState();
    if (mediaQuery.orientation == Orientation.portrait &&
        mediaQuery.size.shortestSide >= 600) {
      itemHeight = mediaQuery.size.height * 0.5;
      boxConstraints = mediaQuery.size.height * 0.5;
      itemWidth = mediaQuery.size.width;
    } else if (mediaQuery.orientation == Orientation.landscape &&
        mediaQuery.size.shortestSide >= 600) {
      itemHeight = mediaQuery.size.height * 0.5;
      boxConstraints = mediaQuery.size.height * 0.5;
      itemWidth = mediaQuery.size.width;
    } else if (mediaQuery.orientation == Orientation.portrait) {
      itemHeight = 280;
      boxConstraints = 250;
      itemWidth = mediaQuery.size.width;
    } else if (mediaQuery.orientation == Orientation.landscape) {
      itemHeight = 380;
      boxConstraints = 350;
      itemWidth = 700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints.loose(new Size(mediaQuery.size.width, boxConstraints)),
      child: Swiper(
          containerWidth: mediaQuery.size.width,
          layout: SwiperLayout.TINDER,
//          itemWidth: itemWidth,
//          itemHeight: itemHeight,
          itemWidth: double.infinity,
          itemHeight: double.infinity,
          viewportFraction: 0.8,
          scale: 0.9,
          scrollDirection: Axis.horizontal,
          control: SwiperControl(
            color: Colors.black,
            size: 20,
            iconNext: Icons.arrow_forward,
            iconPrevious: Icons.arrow_back,
          ),
          itemBuilder: (context, index) {
            return customContainer(index, context);
          },
          itemCount: 5),
    );
  }

  Container customContainer(index, context) {
    if (index == 0) {
      return Container(
          color: Colors.white,
          child: DonutAutoLabelChart.withSampleData(data, context));
    } else if (index == 1) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context).translate('Alarms'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(
                    Icons.error,
                    size: 120,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '0- ${AppLocalizations.of(context).translate('Speed')}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '0- ${AppLocalizations.of(context).translate('Geozone')}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '0- ${AppLocalizations.of(context).translate("Low battery GPS")}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '47- ${AppLocalizations.of(context).translate("Start UP")}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '0- ${AppLocalizations.of(context).translate("Open hood")}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (index == 2) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  '${AppLocalizations.of(context).translate("Total Distance")}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.airport_shuttle,
                      size: 120,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        '120 ${AppLocalizations.of(context).translate("KM/D")}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (index == 3) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  '${AppLocalizations.of(context).translate("DRAINING")}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 120,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        '${AppLocalizations.of(context).translate("No Data")}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (index == 4) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  '${AppLocalizations.of(context).translate("TOTAL PARK CONSUMPTION")}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.local_parking,
                      size: 120,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        '${AppLocalizations.of(context).translate("No Data")}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      child: Text(
        "${AppLocalizations.of(context).translate("Wrong")}",
        style: TextStyle(color: Colors.red.shade900),
      ),
      color: Colors.white,
    );
  }
}
