import 'package:dcsmobile/pages/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageDecoration _pageDecoration = PageDecoration(
    pageColor: Colors.white,
    imagePadding: EdgeInsets.only(top: 30),
  );

  final TextStyle _textStyle = GoogleFonts.gfsDidot(fontSize: 20);

  final double _width = 280;

  final double _height = 200;

  final EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();

  @override
  Widget build(BuildContext context) {
    var listPagesViewModel = [
      PageViewModel(
        decoration: _pageDecoration,
        title: "Tableau de bord",
        bodyWidget: Container(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "Le tableau de bord vous donne une idée générale sur vos véhicules",
                style: _textStyle,
              ),
            ),
          ),
        ),
        image:
            const Image(image: AssetImage('assets/introduction/dashboard.png')),
      ),
      PageViewModel(
        decoration: _pageDecoration,
        title: "Position",
        bodyWidget: Container(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "L'interface Position vous permet de connaître la position actuelle d'un véhicule",
                style: _textStyle,
              ),
            ),
          ),
        ),
        image: const Image(
            image: AssetImage('assets/introduction/vehicle_live.png')),
      ),
      PageViewModel(
        decoration: _pageDecoration,
        title: "Historique",
        bodyWidget: Container(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "A partir de l'historique vous pouvez voir le trajet suit par un véhicule durant la dérnière 24 heures",
                style: _textStyle,
              ),
            ),
          ),
        ),
        image:
            const Image(image: AssetImage('assets/introduction/history.png')),
      ),
      PageViewModel(
        decoration: _pageDecoration,
        title: "Liste des véhicules",
        bodyWidget: Container(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "Liste véhicules vous donne la liste des véhicules aussi vous pouvez chercher un véhicule par son modèle",
                style: _textStyle,
              ),
            ),
          ),
        ),
        image: const Image(
            image: AssetImage('assets/introduction/list_vehicles.png')),
      ),
      PageViewModel(
        decoration: _pageDecoration,
        title: "Rapport",
        bodyWidget: Container(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "Cette fonctionnalité vous permet de voir un rapport détaillé sur un véhicule",
                style: _textStyle,
              ),
            ),
          ),
        ),
        image:
            const Image(image: AssetImage('assets/introduction/rapport.png')),
      ),
      PageViewModel(
        decoration: _pageDecoration,
        title: "Alarms",
        bodyWidget: Container(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                "Cette fonctionnalité vous permet d'activer les notifications selon des conditions comme la vitesse maximale",
                style: _textStyle,
              ),
            ),
          ),
        ),
        image:
            const Image(image: AssetImage('assets/introduction/notifications.png')),
      ),
    ];
    return IntroductionScreen(
      pages: listPagesViewModel,
      onDone: () {
        toDashboard();
      },
      onSkip: () {
        toDashboard();
      },
      showSkipButton: true,
      skip: const Text('Passer'),
      next: const Icon(Icons.navigate_next),
      done: const Text("Terminé", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Colors.deepOrange,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
    );
  }

  toDashboard() {
    if(Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (Route<dynamic> route) => false);
    }
  }
}
