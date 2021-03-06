import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:flutter/material.dart';

class DonutAutoLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutAutoLabelChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutAutoLabelChart.withSampleData(receivedData, context) {
    return new DonutAutoLabelChart(
      _createSampleData(receivedData, context),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(seriesList,
        animate: true,
        animationDuration: Duration(milliseconds: 500),
        behaviors: [
          new charts.DatumLegend(
            outsideJustification: charts.OutsideJustification.endDrawArea,
            horizontalFirst: false,
            desiredMaxRows: 2,
            cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
            entryTextStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.black, fontSize: 14),
          )
        ],
        defaultRenderer:
            new charts.ArcRendererConfig(arcWidth: 600, arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              insideLabelStyleSpec: new charts.TextStyleSpec(
                color: charts.Color(r: 0, g: 0, b: 0),
                fontSize: 14,
              ),
              labelPosition: charts.ArcLabelPosition.outside)
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
      receivedData, context) {
    var data;
    if (receivedData != null) {
      if (receivedData['firstRow']['moving'] == 0 &&
          receivedData['firstRow']['parked'] == 0) {
        data = [
          //TODO: change renewal with all
          new VehicleStatus(
              "all",
              num.parse(receivedData['firstRow']['all'].toString()) ?? 0,
              Colors.green),
        ];
      } else {
        data = [
          new VehicleStatus(
              AppLocalizations.of(context).translate("Moving"),
              num.parse(receivedData['firstRow']['moving'].toString()) ?? 0,
              Colors.green),
          new VehicleStatus(
              AppLocalizations.of(context).translate("Parked"),
              num.parse(receivedData['firstRow']['parked'].toString()) ?? 0,
              Colors.blueAccent),
        ];
      }
    } else {
      data = [
        new VehicleStatus(AppLocalizations.of(context).translate("Moving"), 0,
            Colors.green),
        new VehicleStatus(AppLocalizations.of(context).translate("Parked"), 0,
            Colors.blueAccent),
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
