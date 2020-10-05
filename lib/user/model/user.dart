import 'package:flutter/material.dart';
import 'package:platzi_trips_app/place/model/place.dart';

class UserData {
  final String uid;
  final String photoURL;
  final String name;
  final String email;
  final List<Place> myPlaces;
  final List<Place> myFavoritePlaces;

  UserData({
    Key key,
    @required this.uid,
    @required this.name,
    @required this.email,
    @required this.photoURL,
    this.myPlaces,
    this.myFavoritePlaces
  });
}