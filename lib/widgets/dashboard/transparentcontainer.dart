import 'package:dcsmobile/pages/Position.dart';
import 'package:flutter/material.dart';

class TransparentContainer extends StatefulWidget {
  final IconData icon;
  final quantity;
  final description;

  TransparentContainer({this.icon, this.quantity, this.description}) : super();

  @override
  _TransparentContainerState createState() =>
      _TransparentContainerState(this.icon, this.quantity, this.description);
}

class _TransparentContainerState extends State<TransparentContainer> {
  final IconData icon;
  final quantity;
  final description;

  _TransparentContainerState(this.icon, this.quantity, this.description);

  double _fontSize;
  double _iconSize;

  @override
  Widget build(BuildContext context) {
    if ((MediaQuery.of(context).size.width < 550 &&
            MediaQuery.of(context).orientation == Orientation.landscape) ||
        (MediaQuery.of(context).size.width < 400 &&
            MediaQuery.of(context).orientation == Orientation.portrait)) {
      _iconSize = 30;
      _fontSize = 20;
//      print("phone shortest size");
    } else if (MediaQuery.of(context).orientation == Orientation.portrait &&
        MediaQuery.of(context).size.shortestSide >= 600) {
      _iconSize = 40;
      _fontSize = 30;
//      print("tablet portrait");
    } else if (MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.shortestSide >= 550) {
      _iconSize = 50;
      _fontSize = 30;
//      print("tablet landscape");
    } else {
      _iconSize = 40;
      _fontSize = 20;
//      print("size ${MediaQuery.of(context).size.shortestSide}");
    }
    return InkResponse(
      containedInkWell: true,
      splashColor: Colors.black,
      onTap: () {
        if(quantity != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Position(description, "Live"),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        height: 140,
        width: 220,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Positioned(
                    left: 2.0,
                    top: 4.0,
                    child: Icon(
                      icon,
                      color: Colors.black54,
                      size: _iconSize,
                    ),
                  ),
                  Icon(
                    icon,
                    color: Colors.white,
                    size: _iconSize,
                  ),
                ],
              ),
              Text(
                quantity.toString(),
                style: TextStyle(
                    shadows: [
                      Shadow(
                        blurRadius: .5,
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                    color: Colors.white,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: TextStyle(
                    shadows: [
                      Shadow(
                        blurRadius: .5,
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                    color: Colors.white,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
