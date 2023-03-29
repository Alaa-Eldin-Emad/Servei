import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etaproject/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/directions_model.dart';
import '../models/directions_repository.dart';

class LocationCubit extends Cubit<LocationStates> {
  LocationCubit() : super(LocationInitialState());

  static LocationCubit get(context) => BlocProvider.of(context);
  GoogleMapController? mapController1;

  Future getPermission() async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServiceEnabled) {
      await Geolocator.requestPermission();
    }
  }

  Set<Marker> markers = {};

  // user info
  var currentLocationUser;
  var latUser;
  var langUser;

  // provider info
  var currentLocationProvider;
  var latProvider;
  var langProvider;
LatLng ?lngUser,lngProvider;
  getLatAndLong({uId, mode}) {
    if (mode == 'user') {
      currentLocationUser = Geolocator.getCurrentPosition().then((value) {
        latUser = value.latitude;
        langUser = value.longitude;
        print('lat user $latUser');
        print('lang user $langUser');
         lngUser = LatLng(latUser, langUser);
        FirebaseFirestore.instance.collection(mode).doc(uId).set({
          'current location': GeoPoint(value.latitude, value.longitude),
          'mode': mode,
        }, SetOptions(merge: true));
        Marker marker = Marker(
            markerId: MarkerId(uId),
            position: LatLng(latUser, langUser),
            infoWindow: InfoWindow(title: uId));
        print(marker.markerId.value);
        markers.removeWhere((element) => element.markerId.value == uId);
        markers.add(marker);
        print('markers ${markers.length}');
        mapController1?.animateCamera(CameraUpdate.newLatLng(lngUser!));
        emit(GetCurrentLocationSuccess());
      }).catchError((error) {
        print(error.toString());
        emit(GetCurrentLocationError(error.toString()));
      });
    } else {
      currentLocationProvider = Geolocator.getCurrentPosition().then((value) {
        latProvider = value.latitude;
        langProvider = value.longitude;
        print('lat provider $latProvider');
        print('lang provider$langProvider');
        lngProvider = LatLng(latProvider, langProvider);
        FirebaseFirestore.instance.collection(mode).doc(uId).set({
          'current location': GeoPoint(value.latitude, value.longitude),
          'mode': mode,
        }, SetOptions(merge: true));
        Marker marker = Marker(
            markerId: MarkerId(uId),
            position: LatLng(latProvider, langProvider),
            infoWindow: InfoWindow(title: uId));
        print(marker.markerId.value);
        markers.removeWhere((element) => element.markerId.value == uId);
        markers.add(marker);
        print('markers ${markers.length}');
        mapController1?.animateCamera(CameraUpdate.newLatLng(lngProvider!));
        emit(GetCurrentLocationSuccess());
      }).catchError((error) {
        print(error.toString());
        emit(GetCurrentLocationError(error.toString()));
      });
    }
  }

  List<String> screensByDrawer = [
    'Home page',
    'Settings',
    'Language',
  ];
  List<IconData> drawerIcons = [
    Icons.home,
    Icons.miscellaneous_services,
    Icons.language,
  ];

  Widget buildDrawer() =>
      Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal),
                  accountName: Text('admin'),
                  accountEmail: Text('admin@gmail.com'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Text(
                      'A',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  )),
              // buildDrawerItem(
              //     cubit.screensByDrawer, cubit.drawerIcons, context),
              // Center(
              //   child: ElevatedButton(
              //       onPressed: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => ProviderScreen()));
              //       },
              //       style: ButtonStyle(
              //           backgroundColor:
              //           MaterialStateProperty.all(Colors.teal)),
              //       child: Text('Provider mode')),
              // )
            ],
          ));

  bool isDark = false;
  String style = '';
  GoogleMapController? mapController2;

//   changeMood({fromShared1, context, fromShared2}) async {
//     if (fromShared1 != null) {
//       isDark = fromShared1;
//       style = fromShared2;
//       emit(MoodChangesSuccessfully());
//       print('saved abl kida');
//       if (isDark) {
//         style = await DefaultAssetBundle.of(context)
//             .loadString('assets/map_style_dark.json');
//         await mapController1?.setMapStyle(style);
//         // await CacheHelper.saveStringData(key: 'mapStyle', value: style);
//         // await CacheHelper.saveBoolData(key: 'dark', value: isDark);
//         emit(DarkMapMood());
//         print('saved abl kida dark');
//       } else {
//         style = await DefaultAssetBundle.of(context)
//             .loadString('assets/map_style_light.json');
//         await mapController1?.setMapStyle(style);
// //      await CacheHelper.saveStringData(key: 'mapStyle', value: style);
// // await CacheHelper.saveBoolData(key: 'dark', value: isDark);
//         emit(LightMapMood());
//         print('saved abl kida light');
//       }
//     } else {
//       isDark = !isDark;
//       if (isDark) {
//         style = await DefaultAssetBundle.of(context)
//             .loadString('assets/map_style_dark.json');
//         await mapController1!.setMapStyle(style);
//         // await CacheHelper.saveStringData(key: 'mapStyle', value: style);
//         // await CacheHelper.saveBoolData(key: 'dark', value: isDark);
//         emit(DarkMapMood());
//         print('saved dark 1');
//       } else {
//         style = await DefaultAssetBundle.of(context)
//             .loadString('assets/map_style_light.json');
//         await mapController1?.setMapStyle(style);
//         // await CacheHelper.saveStringData(key: 'mapStyle', value: style);
//         // await CacheHelper.saveBoolData(key: 'dark', value: isDark);
//         emit(LightMapMood());
//         print('saved light 1');
//       }
//     }
//   }
  changeMood(context) async
  {
    isDark = !isDark;
    emit(MoodChangesSuccessfully());
    if (isDark) {
      style = await DefaultAssetBundle.of(context).loadString(
          'assets/map_style_dark.json');
      await mapController1?.setMapStyle(style);
      emit(DarkMapMood());
    }
    else {
      style = await DefaultAssetBundle.of(context).loadString(
          'assets/map_style_light.json');
      await mapController1?.setMapStyle(style);
      emit(LightMapMood());
    }
  }

  var liveLat;
  var liveLang;

  void realTimeTracking(String uId, String service) {
    Geolocator.getPositionStream().listen((event) {
      // FirebaseFirestore.instance.collection('users').doc(uId).set({
      //   'uId': uId,
      //   'real location': GeoPoint(event.latitude, event.longitude),
      // }, SetOptions(merge: true));
      FirebaseFirestore.instance.collection('providers').doc(uId).set({
        'real location': GeoPoint(event.latitude, event.longitude),
        'mode': 'provider',
        'service': service
      }, SetOptions(merge: true));
    });

    // FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
    //   for (var element in event.docChanges) {
    //     markers.add(Marker(
    //         markerId: MarkerId(uId),
    //         infoWindow: InfoWindow(title: 'user'),
    //         position: LatLng(element.doc.data()?['real location'].latitude,
    //             element.doc.data()?['real location'].longitude)));
    //     liveLat = element.doc.data()?['real location'].latitude;
    //     liveLang = element.doc.data()?['real location'].longitude;
    //     emit(LiveLocation());
    //   }
    //
    //   mapController2
    //       ?.animateCamera(CameraUpdate.newLatLng(LatLng(liveLat, liveLang)));
    // });

    FirebaseFirestore.instance
        .collection('providers')
        .snapshots()
        .listen((event) {
      for (var element in event.docChanges) {
        markers.add(Marker(
            markerId: MarkerId(element.doc.id),
            infoWindow: InfoWindow(title: 'provider'),
            position: LatLng(element.doc.data()?['real location'].latitude,
                element.doc.data()?['real location'].longitude)));
        liveLat = element.doc.data()?['real location'].latitude;
        liveLang = element.doc.data()?['real location'].longitude;
        emit(LiveLocation());
      }

      mapController2
          ?.animateCamera(CameraUpdate.newLatLng(LatLng(liveLat, liveLang)));
    });
  }

  bool appeared = true;

  buttonDisappeared() {
    appeared = false;
    emit(ButtonDisappeared());
  }

  // void changeLanguageToArabic(BuildContext context) async
  // {
  //   await context.setLocale(Locale('ar'));
  //   emit(ArabicState());
  // }

  // void changeLanguageToEnglish(BuildContext context) async
  // {
  //   await context.setLocale(Locale('en'));
  //   emit(EnglishState());
  // }

  String lang = '';

  void changeRadioVal(val) {
    lang = val;
    if (val == 'Arabic') {
      emit(ArabicState());
    }
    else if (val == 'English') {
      emit(EnglishState());
    }
  }

  //variables for directions
  //Set<Polyline>polylines = <Polyline>{};
  late String time;
  late String distance;


  List<ServiceItem> services = [
    ServiceItem(
        name: 'Tow Truck', image: 'assets/new-tow.png', isClicked: false),
    ServiceItem(name: 'winch', image: 'assets/new-win.png', isClicked: false),
    ServiceItem(
        name: 'Emergency',
        image: 'assets/front-line (1).png',
        isClicked: false),
    ServiceItem(
        name: 'First Aid',
        image: 'assets/first-aid-kit (1).png',
        isClicked: false),
    ServiceItem(name: 'Fuel', image: 'assets/fuel.png', isClicked: false),
    ServiceItem(
        name: 'JumpStart', image: 'assets/battery.png', isClicked: false),
    ServiceItem(name: 'Key Lockout', image: 'assets/key.png', isClicked: false),
    ServiceItem(name: 'Tire Change', image: 'assets/tire.png', isClicked: false)
  ];
  List<ServiceItem> emergencyItems = [
    ServiceItem(
        name: 'Fire Stations',
        image: 'assets/fire-truck.png',
        isClicked: false),
    ServiceItem(

        name: 'Hospitals', image: 'assets/hospital.png', isClicked: false),
    ServiceItem(
        name: 'Police Stations',
        image: 'assets/police-station.png',
        isClicked: false)
  ];


  List<ServiceItem> servicesClicked = [];

  bool isServiceClicked(ServiceItem model, uId, serviceName) {
    model.isClicked = !model.isClicked;

    if (model.isClicked == true)
    {
      servicesClicked.add(model);
      FirebaseFirestore.instance.collection('provider').doc(uId).set({
        'services': FieldValue.arrayUnion([serviceName])
      }, SetOptions(merge: true));
    } else if (model.isClicked == false && servicesClicked.contains(model))
    {
      servicesClicked.remove(model);
      FirebaseFirestore.instance.collection('provider').doc(uId).set({
        'services': FieldValue.arrayRemove([serviceName])
      }, SetOptions(merge: true));
      print(model.isClicked);
      print(servicesClicked.length);

    }
    emit(ServiceClickedSuccessfully());
    return model.isClicked;
  }
  Directions? info;

  connection()async
  {
    await FirebaseFirestore.instance.collection('provider').get().then((value)
    {
      for (var doc in value.docs)
      {
        lngProvider=LatLng(doc.data()['current location'].latitude, doc.data()['current location'].longitude);
        Marker marker = Marker(icon:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            markerId: MarkerId('provider'),
            position: LatLng(doc.data()['current location'].latitude,doc.data()['current location'].longitude),
            infoWindow: InfoWindow(title: 'provider'));
        markers.add(marker);
        // mapController1?.animateCamera(CameraUpdate.newLatLng(lngProvider!));
        break;
      } });
    final directions =await DirectionsRepository()
        .getDirections(origin: lngUser!, destination: lngProvider!);
    info = directions;
    emit(DirectionsSuccess());
  }
  void removeService(model, uId, serviceName) {
    servicesClicked.remove(model);
    FirebaseFirestore.instance.collection('provider').doc(uId).set(
        {
          'services': FieldValue.arrayRemove([serviceName])
        }, SetOptions(merge: true));

    emit(RemovedSuccessfully());
  }


}
class ServiceItem {
  String image;
  String name;
  bool isClicked;
  ServiceItem(
      {required this.name, required this.image, required this.isClicked});
}
