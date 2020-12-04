class Draining {
  num _id;
  String _deviceID;
  String _name;
  num _timestamp;
  double _kmStart;
  double _kmEnd;

  Draining(this._id, this._deviceID, this._name, this._timestamp, this._kmStart,
      this._kmEnd);

  Draining.withoutID(
      this._deviceID, this._name, this._timestamp, this._kmStart, this._kmEnd);

  String get deviceID => _deviceID;

  set deviceID(String value) {
    _deviceID = value;
  }

  factory Draining.fromJson(Map<dynamic, dynamic> json) {
    return Draining(json["id"], json["deviceID"], json["name"],
        json["timestamp"], json["kmStart"], json["kmEnd"]);
  }

  Map<String, dynamic> toJson() {
    if (_id != null) {
      return {
        "id": _id,
        "deviceID": _deviceID,
        "timestamp": _timestamp,
        "name": _name,
        "kmStart": _kmStart,
        "kmEnd": _kmEnd
      };
    } else {
      return {
        "deviceID": _deviceID,
        "timestamp": _timestamp,
        "name": _name,
        "kmStart": _kmStart,
        "kmEnd": _kmEnd
      };
    }
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  num get timestamp => _timestamp;

  set timestamp(num value) {
    _timestamp = value;
  }

  double get kmStart => _kmStart;

  set kmStart(double value) {
    _kmStart = value;
  }

  double get kmEnd => _kmEnd;

  set kmEnd(double value) {
    _kmEnd = value;
  }

  num get id => _id;

  set id(num value) {
    _id = value;
  }
}
