import 'package:dcsmobile/charts/donutautolabelchart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class CustomSwipper extends StatefulWidget {
  final MediaQueryData mediaQuery;
  final data;

  CustomSwipper({this.mediaQuery, this.data}) : super();

  @override
  _CustomSwipperState createState() => _CustomSwipperState(this.mediaQuery, this.data);
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
            return customContainer(index);
          },
          itemCount: 2),
    );
  }

  Container customContainer(index) {
    if (index == 0) {
      return Container(
          // color: Color.fromRGBO(250, 224, 216, 1),
          color: Colors.white,
          child: DonutAutoLabelChart.withSampleData(data));
    } else if (index == 1) {
      return Container(
        color: Colors.grey.shade200,
      );
    } else if (index == 2) {
      return Container(
        color: Colors.grey.shade100,
      );
    } else if (index == 3) {
      return Container(
        color: Colors.grey.shade200,
      );
    } else if (index == 4) {
      return Container(
        color: Colors.grey.shade100,
      );
    }
    return Container(
      child: Text(
        "something's wrong",
        style: TextStyle(color: Colors.red.shade900),
      ),
      color: Colors.white,
    );
  }
}
