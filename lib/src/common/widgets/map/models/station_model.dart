import 'package:client/src/config/constants.dart';

class StationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String stopTime;
  final bool isDeparture;

  StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.stopTime,
    required this.isDeparture,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      stopTime: json['stopTime'],
      isDeparture: json['isDeparture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'stopTime': stopTime,
      'isDeparture': isDeparture,
    };
  }
}

// mock data
final List<StationModel> stationsData = [
  StationModel.fromJson(
    {
      "id": "66730c882cf8fe1f6bcf1c30",
      "name": "정부 대전청사",
      "address": "???",
      "latitude": 36.3612482,
      "longitude": 127.3848091,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c32",
      "name": "유성구청",
      "address": "??",
      "latitude": 36.36210517519867,
      "longitude": 127.35634803771973,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c33",
      "name": "유성문화원",
      "address": "??",
      "latitude": 36.36017613912628,
      "longitude": 127.34118018561429,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c35",
      "name": "월드컵경기장역",
      "address": "??",
      "latitude": 36.36620032438301,
      "longitude": 127.32128620147705,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c36",
      "name": "삼성화재 연수원",
      "address": "??",
      "latitude": MapConstants.defaultLatLng.latitude,
      "longitude": MapConstants.defaultLatLng.longitude,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "66730c882cf8fe1f6bcf1c30",
      "name": "대전역",
      "address": "???",
      "latitude": 36.332326,
      "longitude": 127.434211,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c32",
      "name": "갈마역",
      "address": "??",
      "latitude": 36.35797524955099,
      "longitude": 127.37214088439941,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c34",
      "name": "유성온천역 맥도날드",
      "address": "??",
      "latitude": 36.35438082628037,
      "longitude": 127.3404049873352,
      "stopTime": "",
      "isDeparture": true
    },
  ),
  StationModel.fromJson(
    {
      "id": "667316322cf8fe1f6bcf1c35",
      "name": "현충원역",
      "address": "??",
      "latitude": 36.35954771869189,
      "longitude": 127.32119718761012,
      "stopTime": "",
      "isDeparture": true
    },
  ),
];
