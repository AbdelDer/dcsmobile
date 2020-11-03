class Activity {
  num _startTime;
  num _endTime;
  double _avgSpeed;
  double _distanceKM;
  String _activity;

  num get startTime => _startTime;

  num get endTime => _endTime;

  String get activity => _activity;

  double get distanceKM => _distanceKM?.roundToDouble();

  double get avgSpeed => _avgSpeed?.roundToDouble();

  String get activityTimeAsString {
    final _timeDiff = DateTime.fromMillisecondsSinceEpoch((_endTime * 1000).toInt())
        .difference(DateTime.fromMillisecondsSinceEpoch((_startTime * 1000).toInt()));

    return _printDuration(_timeDiff);
  }

  String get startTimeAsString {
    DateTime startTime = DateTime.fromMillisecondsSinceEpoch((_startTime * 1000).toInt());
    int hour = startTime.hour;
    int minute = startTime.minute;
    if(hour < 10 && minute <10) {
      return '0$hour:0$minute';
    }else if(hour < 10) {
      return '0$hour:$minute';
    }else if(minute < 10) {
      return '$hour:0$minute';
    }
    return '$hour:$minute';
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // if(duration.inHours == 0) return "$twoDigitMinutes:$twoDigitSeconds";
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }

  Activity(this._startTime, this._endTime, this._avgSpeed, this._distanceKM, this._activity);

  Activity.parking(this._startTime, this._endTime, this._activity);

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
        num.parse(json['engineOnTime']),
        num.parse(json['engineOffTime']),
        json['avgSpeed'],
        json['distanceKM'],
        json['activity']);
  }
}
