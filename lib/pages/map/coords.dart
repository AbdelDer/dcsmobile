import 'dart:math';

import 'package:vector_math/vector_math.dart';

class CoordsBetweenTwoGeoPoints {
  _getPathLength(lat1, lng1, lat2, lng2) {
    //calculates the distance between two lat, long coordinate pairs
    var R = 6371000; // radius of earth in m
    var lat1rads = radians(lat1);
    var lat2rads = radians(lat2);
    var deltaLat = radians((lat2 - lat1));
    var deltaLng = radians((lng2 - lng1));
    var a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1rads) * cos(lat2rads) * sin(deltaLng / 2) * sin(deltaLng / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;

    return d;
  }

  _getDestinationLatLong(lat, lng, azimuth, distance) {
    // returns the lat an long of destination point
    // given the start lat, long, aziuth, and distance
    var R = 6378.1; //Radius of the Earth in km
    var brng = radians(azimuth); //Bearing is degrees converted to radians.
    var d = distance / 1000; //Distance m converted to km

    var lat1 = radians(lat); //Current dd lat point converted to radians
    var lon1 = radians(lng); //Current dd long point converted to radians

    var lat2 =
        asin(sin(lat1) * cos(d / R) + cos(lat1) * sin(d / R) * cos(brng));

    var lon2 = lon1 +
        atan2(sin(brng) * sin(d / R) * cos(lat1),
            cos(d / R) - sin(lat1) * sin(lat2));

    //convert back to degrees
    lat2 = degrees(lat2);
    lon2 = degrees(lon2);

    return [lat2, lon2];
  }

  _calculateBearing(lat1, lng1, lat2, lng2) {
    //calculates the azimuth in degrees from start point to end point
    var startLat = radians(lat1);
    var startLong = radians(lng1);
    var endLat = radians(lat2);
    var endLong = radians(lng2);
    var dLong = endLong - startLong;
    var dPhi =
        log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));
    if (dLong.abs() > pi) {
      if (dLong > 0.0) {
        dLong = -(2.0 * pi - dLong);
      } else {
        dLong = (2.0 * pi + dLong);
      }
    }
    var bearing = (degrees(atan2(dLong, dPhi)) + 360.0) % 360.0;
    return bearing;
  }

  getCoords(lat1, lng1, lat2, lng2, speed) {
    // returns every coordinate pair inbetween two coordinate
    // pairs given the desired interval
    // point interval in meters
    var azimuth = this._calculateBearing(lat1, lng1, lat2, lng2);
    var d = this._getPathLength(lat1, lng1, lat2, lng2);
    var interval;
    if(d < 50) {
      interval = 1.0;
    } else {
      if(speed < 67) {
        interval = (speed/5) * (d/950);
      } else if(speed >= 67 && speed < 127) {
        interval = (speed/10) * (d/950);
      } else {
        interval = (d/950);
      }
    }
    print("the distance in meter is : $d and interval is $interval");
    print("$lat1,$lng1");
    print("$lat2,$lng2");
    double remainder = 0;
    int dist = 0;
    if(d != 0) {
      remainder = (d / interval) - (d / interval).floor();
      dist = (d / interval).floor();
    }
    var counter = interval;
    var coords = [];
    coords.add([lat1, lng1]);
    for (var distance in new List<int>.generate(dist, (i) => i)) {
      var coord = this._getDestinationLatLong(lat1, lng1, azimuth, counter);
      counter = counter + interval;
      coords.add(coord);
    }
    coords.add([lat2, lng2]);
    return coords;
  }
}
