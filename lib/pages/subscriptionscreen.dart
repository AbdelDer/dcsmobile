import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/Subscription.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('Subscription')),
          backgroundColor: Colors.deepOrange,
        ),
        drawer: FEDrawer(),
        body: FutureBuilder(
            future: getDevicesSubscription(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.message != null) {
                  return Center(
                    child: Text(
                      snapshot.data.message,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.responseBody.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: snapshot.data.responseBody[index].color,
                          child: ListTile(
                            leading: Icon(
                              Icons.directions_car,
                              color: Colors.black,
                            ),
                            title: Text(
                              snapshot.data.responseBody[index].vehicleModel,
                              style: TextStyle(color: Colors.black),
                            ),
                            trailing: Text(
                                '${snapshot.data.responseBody[index].subscriptionTime.toString()} jours'),
                          ),
                        );
                      });
                }
              } else if (snapshot.hasError) {
                return AlertDialog();
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Future getDevicesSubscription() async {
    var subscriptionDetails;
    await Api.getDevicesSubscription().then((value) {
      subscriptionDetails = value;
      // print('${value.data}');
    }).catchError((error) {});
    return subscriptionDetails;
  }
}
