class Entretien {
  num _id;
  String _deviceID;
  String _name;
  num _timestamp;
  double _price;

  Entretien(this._id, this._deviceID, this._name, this._timestamp, this._price);

  Entretien.withoutID(this._deviceID, this._name, this._timestamp, this._price);

  String get deviceID => _deviceID;

  set deviceID(String value) {
    _deviceID = value;
  }

  factory Entretien.fromJson(Map<dynamic, dynamic> json) {
    return Entretien(json["id"], json["deviceID"], json["name"],
        json["timestamp"], json["price"]);
  }

  Map<String, dynamic> toJson() {
    if (_id != null) {
      return {
        "id": _id,
        "deviceID": _deviceID,
        "timestamp": _timestamp,
        "name": _name,
        "price": _price,
      };
    } else {
      return {
        "deviceID": _deviceID,
        "timestamp": _timestamp,
        "name": _name,
        "price": _price
      };
    }
  }

  double get price => _price;

  set price(double value) {
    _price = value;
  }

  num get timestamp => _timestamp;

  set timestamp(num value) {
    _timestamp = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  num get id => _id;

  set id(num value) {
    _id = value;
  }
}
