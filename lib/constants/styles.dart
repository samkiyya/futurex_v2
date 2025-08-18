import 'package:flutter/material.dart';

class FuturexStyles {
  // Text Styles
  static const TextStyle head = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle ftext = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );
  static const TextStyle ftext2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );
  static const TextStyle ftext3 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );
  static const TextStyle ftext4 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );
  static const TextStyle head2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const TextStyle success = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    letterSpacing: 1.2,
    color: Colors.green,
  );
 static const TextStyle warning = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    letterSpacing: 1.2,
    color: Colors.yellow,
  );
  static const TextStyle normal = TextStyle(
    fontSize: 16.0,
    color: Colors.white,
  );
   static const TextStyle error = TextStyle(
    fontSize: 19.0,
    color: Colors.red,
  );

  // Button Styles
  static final ButtonStyle pbutton = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    textStyle: TextStyle(fontSize: 16.0),
    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
    ),
    elevation: 3.0, // Button elevation
  );
 static final ButtonStyle sbutton = ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    textStyle: TextStyle(fontSize: 16.0),
    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
    ),
    elevation: 3.0, // Button elevation
  );
   static final ButtonStyle tbutton = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    textStyle: TextStyle(fontSize: 16.0),
    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
    ),
    elevation: 3.0, // Button elevation
  );
  // Card Styles
  static const CardTheme cardTheme = CardTheme(
    margin: EdgeInsets.all(8.0),
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
  );

  // Dialog Box Styles
  static const BoxDecoration dialogBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  );

  // Data Cell Styles
  static const BoxDecoration dataCellDecoration = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Colors.grey,
        width: 0.5,
      ),
    ),
  );



}
