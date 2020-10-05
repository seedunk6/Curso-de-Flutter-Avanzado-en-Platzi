// Manejar la subida de la entidad en firestore

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platzi_trips_app/place/model/place.dart';
import 'package:platzi_trips_app/place/ui/widgets/card_image.dart';
import 'package:platzi_trips_app/user/model/user.dart';
import 'package:platzi_trips_app/user/ui/widgets/profile_place.dart';

class CloudFirestoreAPI{

  // Nombres de las colecciones
  final String USERS = "users";
  final String PLACES = "places";

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void updateUserData(UserData user) async{
    DocumentReference ref = _db.collection(USERS).doc(user.uid);
    return await ref.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      'myPlaces': user.myPlaces,
      'myFavoritePlaces': user.myFavoritePlaces,
      'lastSignIn': DateTime.now()
    }, SetOptions(merge: true));
  }

  Future<void> updatePlaceData(Place place) async {
    CollectionReference refPlaces = _db.collection(PLACES);

    User user = _auth.currentUser;
    await refPlaces.add({
      'name' : place.name,
      'description' : place.description,
      'likes' : place.likes,
      'urlImage': place.urlImage,
      'userOwner' : _db.doc("${USERS}/${user.uid}"), // reference..
    }).then((DocumentReference dr) {
      dr.get().then((DocumentSnapshot snapshot ){
        DocumentReference refUsers = _db.collection(USERS).doc(user.uid);
        refUsers.update({
          'myPlaces': FieldValue.arrayUnion([_db.doc("${PLACES}/${ snapshot.id}")])
        });
      });
    });
  }

  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot){
    List<ProfilePlace> profilePlaces = List<ProfilePlace>();
    placesListSnapshot.forEach((p) {

      profilePlaces.add(ProfilePlace(
          Place(
              name: p.data()['name'],
              description: p.data()['description'],
              urlImage: p.data()['urlImage'],
              likes: p.data()['likes'])
      ));

    });

    return profilePlaces;

  }

  List<Place> buildPlaces(List<DocumentSnapshot> placesListSnapshot, UserData user) {
    List<Place> places = List<Place>();

    placesListSnapshot.forEach((p)  {
      Place place = Place(id: p.id, name: p.data()["name"], description: p.data()["description"],
          urlImage: p.data()["urlImage"],likes: p.data()["likes"]
      );
      List usersLikedRefs =  p.data()["usersLiked"];
      place.liked = false;
      usersLikedRefs?.forEach((drUL){
        if(user.uid == drUL.documentID){
          place.liked = true;
        }
      });
      places.add(place);
    });
    return places;
  }

  Future likePlace(Place place, String uid) async {
    await _db.collection(PLACES).doc(place.id).get()
        .then((DocumentSnapshot ds){
      int likes = ds.data()["likes"];

      _db.collection(PLACES).doc(place.id)
          .update({
        'likes': place.liked?likes+1:likes-1,
        'usersLiked':
        place.liked?
        FieldValue.arrayUnion([_db.doc("${USERS}/${uid}")]):
        FieldValue.arrayRemove([_db.doc("${USERS}/${uid}")])
      });


    });
  }

}