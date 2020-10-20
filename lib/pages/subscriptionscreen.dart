import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/models/Subscription.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Abonnement'),
          backgroundColor: Colors.deepOrange,
        ),
        drawer: FEDrawer(),
        body: FutureBuilder(
            future: getDevicesSubscription(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      // print('${snapshot.data}');
                      return Card(
                        color: snapshot.data[index].color,
                        child: ListTile(
                          leading: Icon(Icons.directions_car, color: Colors.black,),
                          title: Text(snapshot.data[index].vehicleModel, style: TextStyle(color: Colors.black),),
                          trailing: Text('${snapshot.data[index].subscriptionTime.toString()} jours'),
                        ),
                      );
                    });
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
      subscriptionDetails = value.data;
      // print('${value.data}');
    }).catchError((error) {
      print('error is $error');
    });
    return subscriptionDetails;
  }
}
