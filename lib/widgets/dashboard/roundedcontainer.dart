import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:flutter/material.dart';

class RoundedContainer extends StatefulWidget {
  final colors;
  final maxSubject;
  final maxValue;
  final model;

  RoundedContainer({this.colors, this.maxSubject, this.maxValue, this.model})
      : super();

  @override
  _RoundedContainerState createState() => _RoundedContainerState(
      this.colors, this.maxSubject, this.maxValue, this.model);
}

class _RoundedContainerState extends State<RoundedContainer> {
  final colors;
  final maxSubject;
  final maxValue;
  final model;

  double _heightContainer;
  double _widthContainer;
  double _fontSize;

  _RoundedContainerState(
      this.colors, this.maxSubject, this.maxValue, this.model);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait &&
        MediaQuery.of(context).size.shortestSide >= 600) {
      _heightContainer = 170;
      _widthContainer = 170;
      _fontSize = 11;
//      print("tablet portrait");
    } else if (MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.shortestSide >= 550) {
      _heightContainer = 170;
      _widthContainer = 170;
      _fontSize = 11;
//      print("tablet landscape");
    } else {
      _heightContainer = 120;
      _widthContainer = 140;
      _fontSize = 11;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(10),
          height: _heightContainer,
          width: _widthContainer,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: this.colors),
            // boxShadow: [
            //   BoxShadow(color: Colors.black, blurRadius: 10.0),
            // ],
            // borderRadius: BorderRadius.circular(60.0),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  "${AppLocalizations.of(context).translate("Max")}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  maxSubject ?? '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  maxValue ?? '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    model ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
