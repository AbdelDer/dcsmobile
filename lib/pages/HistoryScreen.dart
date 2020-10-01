import 'package:dcsmobile/pages/vehicleliveposition.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {

  String _deviceID;
  String _vehicleModel;
  String _option;


  HistoryScreen(this._deviceID, this._vehicleModel, this._option);

  @override
  _HistoryScreenState createState() => _HistoryScreenState(_deviceID, _vehicleModel, _option);
}

class _HistoryScreenState extends State<HistoryScreen> {
  var _selectedType;
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  String _deviceID;
  String _vehicleModel;
  String _option;

  _HistoryScreenState(this._deviceID, this._vehicleModel, this._option);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      title: Center(
        child: Text(
          "Date début/fin: ${_vehicleModel}",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(
            child: GestureDetector(
              onTap: () async {
                _pickDateTime("start");
              },
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_pickedDateTimeStart.year}-${_pickedDateTimeStart.month}-${_pickedDateTimeStart.day} ${_pickedDateTimeStart.hour}:${_pickedDateTimeStart.minute}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Date fin:",
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await _pickDateTime("end");
                },
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_pickedDateTimeEnd.year}-${_pickedDateTimeEnd.month}-${_pickedDateTimeEnd.day} ${_pickedDateTimeEnd.hour}:${_pickedDateTimeEnd.minute}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ]),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text("Valider", style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VehicleLivePosition(deviceID: this._deviceID, option: this._option),
                  ),
                );
              },
              color: Colors.deepOrange,
            ),
          ),
        ),
      ],
    );
  }

  _pickDateTime(startOrEnd) async {
    DateTime pickedDate;
    TimeOfDay time;
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      pickedDate = date;
    }
    TimeOfDay t =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      time = t;
    }
    setState(() {
      if (startOrEnd == "start") {
        _pickedDateTimeStart = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, time.hour, time.minute);
      } else {
        _pickedDateTimeEnd = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, time.hour, time.minute);
      }
    });
  }
}
