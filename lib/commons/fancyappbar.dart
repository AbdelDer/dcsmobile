import 'package:flutter/material.dart';

//this app bar used in dashboard only
class FancyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String text; //Specify content from outside
  final Color statusBarColor; //Set the color of statusbar
  final double contentHeight = 80.0;
  final bool rightShow;
  final VoidCallback callback;
  final GlobalKey<ScaffoldState> scaffoldKey;

  FancyAppBar({
    this.scaffoldKey,
    this.text,
    this.statusBarColor,
    this.rightShow,
    this.callback,
  }) : super();

  @override
  _FancyAppBarState createState() => _FancyAppBarState(this.scaffoldKey);

  @override
  Size get preferredSize => new Size.fromHeight(contentHeight);
}

class _FancyAppBarState extends State<FancyAppBar> {
  final GlobalKey<ScaffoldState> scaffoldKey;
  double _iconSize;

  _FancyAppBarState(this.scaffoldKey);

  @override
  Widget build(BuildContext context) {
    var divHeight = MediaQuery.of(context).size.height * 0.6;// was multiplied by 0.5
    if (MediaQuery.of(context).orientation == Orientation.portrait &&
        MediaQuery.of(context).size.shortestSide >= 600) {
      _iconSize = 40.0;
      divHeight = MediaQuery.of(context).size.height * 0.45;// was multiplied by 0.5
//      print("tablet portrait");
    } else if (MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.shortestSide >= 550) {
      _iconSize = 40.0;
      divHeight = MediaQuery.of(context).size.height * 0.75;// was multiplied by 0.5
//      print("tablet landscape");
    } else {
      _iconSize = 30.0;
      if(MediaQuery.of(context).orientation == Orientation.landscape) {
        divHeight = MediaQuery.of(context).size.height * 0.95;
      }
    }
    return Container(
      height: divHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.greenAccent.shade200,
              Colors.orangeAccent.shade200
            ]),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 5.0),
        ],
        // borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(10.0),
        //     bottomRight: Radius.circular(10.0))
      ),
      alignment: Alignment.topCenter,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 40),
               child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    child: Icon(
                    Icons.menu,
                    size: _iconSize,
                    color: Colors.white,
                  ),
                  onTap: () {
                    scaffoldKey.currentState.openDrawer();
                  },
                ),
              ],
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 30),
            child: GestureDetector(
              child: Stack(children: <Widget>[
                Positioned(
                  left: 1.5,
                  top: 1.5,
                  child: Icon(
                    Icons.exit_to_app,
                    color: Colors.black54,
                    size: _iconSize,
                  ),
                ),
                Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: _iconSize,
                ),
              ]),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
            ),
          )
        ],
      ),
    );
  }
}
