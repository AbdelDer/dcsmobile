import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DonutAutoLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutAutoLabelChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutAutoLabelChart.withSampleData(receivedData) {
    return new DonutAutoLabelChart(
      _createSampleData(receivedData),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(seriesList,
        animate: true,
        animationDuration: Duration(seconds: 1),
        behaviors: [
          new charts.DatumLegend(
            outsideJustification: charts.OutsideJustification.endDrawArea,
            horizontalFirst: false,
            desiredMaxRows: 2,
            cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
            entryTextStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.black, fontSize: 20),
          )
        ],
        defaultRenderer:
            new charts.ArcRendererConfig(arcWidth: 300, arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              insideLabelStyleSpec: new charts.TextStyleSpec(
                color: charts.Color(r: 0, g: 0, b: 0),
                fontSize: 15,
              ),
              labelPosition: charts.ArcLabelPosition.inside)
        ]));
    // seriesList,
    //   animate: animate,
    // Configure the width of the pie slices to 60px. The remaining space in
    // the chart will be left as a hole in the center.
    //
    // [ArcLabelDecorator] will automatically position the label inside the
    // arc if the label will fit. If the label will not fit, it will draw
    // outside of the arc with a leader line. Labels can always display
    // inside or outside using [LabelPosition].
    //
    // Text style for inside / outside can be controlled independently by
    // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
    //
    // Example configuring different styles for inside/outside:
    //       new charts.ArcLabelDecorator(
    //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
    //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
    // defaultRenderer: new charts.ArcRendererConfig(
    //     arcWidth: 60,
    //     arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<VehicleStatus, String>> _createSampleData(
      receivedData) {
    var data;
    if (receivedData != null) {
      if(receivedData['firstRow']['moving'] == 0 && receivedData['firstRow']['parked'] == 0) {
        data = [
          //TODO: change renewal with all
          new VehicleStatus("all", num.parse(receivedData['firstRow']['all'].toString()) ?? 0,
              Colors.orangeAccent.shade200),
        ];
      }else {
        data = [
          new VehicleStatus("En marche", num.parse(receivedData['firstRow']['moving'].toString()) ?? 0,
              Colors.orangeAccent.shade200),
          new VehicleStatus("En parking", num.parse(receivedData['firstRow']['parked'].toString()) ?? 0,
              Colors.deepOrange.shade200),
        ];
      }
    } else {
      data = [
        new VehicleStatus("En marche", 0, Colors.orangeAccent.shade200),
        new VehicleStatus("En parking", 0, Colors.deepOrange.shade200),
      ];
    }

    return [
      new charts.Series<VehicleStatus, String>(
        id: 'vehicle',
        domainFn: (VehicleStatus vstatus, _) => vstatus.status,
        measureFn: (VehicleStatus vstatus, _) => vstatus.value,
        data: data,
        colorFn: (VehicleStatus vstatus, _) =>
            charts.ColorUtil.fromDartColor(vstatus.colorVal),
      )
    ];
  }
}

/// Sample linear data type.
class VehicleStatus {
  final String status;
  final num value;
  final Color colorVal;

  VehicleStatus(this.status, this.value, this.colorVal);
}
