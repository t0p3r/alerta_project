import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends ChangeNotifier {
  Position? currentPosition;
  String currentAddress = "Locating GPS coordinates...";
  bool isLocating = false;

  Future<Position?> getCurrentLocation() async {
    isLocating = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress = "Location services disabled on device";
        isLocating = false;
        notifyListeners();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress = "Location permission denied";
          isLocating = false;
          notifyListeners();
          return null;
        }
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to human-readable address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          currentAddress = "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";
        }
      } catch (e) {
        currentAddress = "Lat: ${currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${currentPosition!.longitude.toStringAsFixed(4)}";
      }

      isLocating = false;
      notifyListeners();
      return currentPosition;
    } catch (e) {
      isLocating = false;
      currentAddress = "GPS unavailable. Please enter landmark.";
      notifyListeners();
      return null;
    }
  }
}
