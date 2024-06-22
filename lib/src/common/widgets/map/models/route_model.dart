import 'package:client/src/common/widgets/map/models/station_model.dart';
import 'package:client/src/config/constants.dart';

class RouteModel {
  final String id;
  final String name;
  final List<StationModel> departureStations;
  final List<StationModel> arrivalStations;

  RouteModel({
    required this.id,
    required this.name,
    required this.departureStations,
    required this.arrivalStations,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      name: json['name'],
      departureStations: (json['departureStations'] as List)
          .map((stationJson) => StationModel.fromJson(stationJson))
          .toList(),
      arrivalStations: (json['arrivalStations'] as List)
          .map((stationJson) => StationModel.fromJson(stationJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departureStations': departureStations.map((e) => e.toJson()).toList(),
      'arrivalStations': arrivalStations.map((e) => e.toJson()).toList(),
    };
  }

  static List<RouteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => RouteModel.fromJson(json)).toList();
  }
}

// mock data
final List<RouteModel> routesData = [
  RouteModel.fromJson(
    {
      'id': "1",
      'name': '1호차',
      'departureStations': [
        {
          "id": "66730c882cf8fe1f6bcf1c30",
          "name": "정부 대전청사",
          "address": "???",
          "latitude": 36.3612482,
          "longitude": 127.3848091,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c32",
          "name": "유성구청",
          "address": "??",
          "latitude": 36.36210517519867,
          "longitude": 127.35634803771973,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c33",
          "name": "유성문화원",
          "address": "??",
          "latitude": 36.36017613912628,
          "longitude": 127.34118018561429,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c35",
          "name": "월드컵경기장역",
          "address": "??",
          "latitude": 36.36620032438301,
          "longitude": 127.32128620147705,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c36",
          "name": "삼성화재 연수원",
          "address": "??",
          "latitude": MapConstants.defaultLatLng.latitude,
          "longitude": MapConstants.defaultLatLng.longitude,
          "stopTime": "",
          "isDeparture": true
        },
      ],
      'arrivalStations': [
        {
          "id": "667316322cf8fe1f6bcf1c36",
          "name": "삼성화재 연수원",
          "address": "??",
          "latitude": MapConstants.defaultLatLng.latitude,
          "longitude": MapConstants.defaultLatLng.longitude,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "667316322cf8fe1f6bcf1c35",
          "name": "월드컵경기장역",
          "address": "??",
          "latitude": 36.367133366202644,
          "longitude": 127.31974857561589,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "667316322cf8fe1f6bcf1c33",
          "name": "유성문화원",
          "address": "??",
          "latitude": 36.36000333899987,
          "longitude": 127.34104071074552,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "667316322cf8fe1f6bcf1c32",
          "name": "유성구청",
          "address": "??",
          "latitude": 36.361595426357425,
          "longitude": 127.35713124275208,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "66730c882cf8fe1f6bcf1c30",
          "name": "정부 대전청사",
          "address": "???",
          "latitude": 36.3612482,
          "longitude": 127.3848091,
          "stopTime": "",
          "isDeparture": false
        },
      ]
    },
  ),
  RouteModel.fromJson(
    {
      'id': "2",
      'name': '2호차',
      'departureStations': [
        {
          "id": "66730c882cf8fe1f6bcf1c30",
          "name": "대전역",
          "address": "???",
          "latitude": 36.332326,
          "longitude": 127.434211,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c32",
          "name": "갈마역",
          "address": "??",
          "latitude": 36.35797524955099,
          "longitude": 127.37214088439941,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c34",
          "name": "유성온천역 맥도날드",
          "address": "??",
          "latitude": 36.35438082628037,
          "longitude": 127.3404049873352,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c35",
          "name": "현충원역",
          "address": "??",
          "latitude": 36.35954771869189,
          "longitude": 127.32119718761012,
          "stopTime": "",
          "isDeparture": true
        },
        {
          "id": "667316322cf8fe1f6bcf1c36",
          "name": "삼성화재 연수원",
          "address": "??",
          "latitude": MapConstants.defaultLatLng.latitude,
          "longitude": MapConstants.defaultLatLng.longitude,
          "stopTime": "",
          "isDeparture": true
        },
      ],
      'arrivalStations': [
        {
          "id": "667316322cf8fe1f6bcf1c36",
          "name": "삼성화재 연수원",
          "address": "??",
          "latitude": MapConstants.defaultLatLng.latitude,
          "longitude": MapConstants.defaultLatLng.longitude,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "667316322cf8fe1f6bcf1c35",
          "name": "현충원역",
          "address": "??",
          "latitude": 36.35912466956739,
          "longitude": 127.32126124303318,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "667316322cf8fe1f6bcf1c34",
          "name": "유성온천역 맥도날드",
          "address": "??",
          "latitude": 36.35370816824952,
          "longitude": 127.34103087489542,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "667316322cf8fe1f6bcf1c32",
          "name": "갈마역",
          "address": "??",
          "latitude": 36.357560516875424,
          "longitude": 127.37274169921875,
          "stopTime": "",
          "isDeparture": false
        },
        {
          "id": "66730c882cf8fe1f6bcf1c30",
          "name": "대전역",
          "address": "???",
          "latitude": 36.332326,
          "longitude": 127.434211,
          "stopTime": "",
          "isDeparture": false
        },
      ]
    },
  ),
];
