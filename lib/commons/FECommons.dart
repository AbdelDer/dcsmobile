import 'package:flutter/material.dart';

class FECommons {
  static final String _title = "Tracking App";

  static AppBar get appBar => AppBar(
        
        elevation: .1,
        title: Text(_title),
        centerTitle: true,
        backgroundColor: Colors.pink.shade500,
        automaticallyImplyLeading: true,
        // actionsIconTheme:
        //     IconThemeData(size: 30.0, color: Colors.black, opacity: 10.0),
        // actions: <Widget>[
        //   Padding(
        //       padding: EdgeInsets.only(right: 20.0),
        //       child: GestureDetector(
        //         onTap: () {},
        //         child: Icon(
        //           Icons.search,
        //           size: 26.0,
        //         ),
        //       )),
        //   Padding(
        //       padding: EdgeInsets.only(right: 20.0),
        //       child: GestureDetector(
        //         onTap: () {},
        //         child: Icon(Icons.more_vert),
        //       )),
        // ],
      );
}
