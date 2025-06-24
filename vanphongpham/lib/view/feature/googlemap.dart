import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopLocationMap extends StatefulWidget {
  const ShopLocationMap({Key? key}) : super(key: key);

  @override
  _ShopLocationMapState createState() => _ShopLocationMapState();
}

class _ShopLocationMapState extends State<ShopLocationMap> {
  late GoogleMapController mapController;
  final List<Map<String, dynamic>> shopLocations = [
    {
      'name': 'Cửa hàng văn phòng phẩm Trung Tâm',
      'latitude': 10.8231,
      'longitude': 106.6297,
      'address': '123 Đường ABC, Quận 1, TP.HCM'
    },
    {
      'name': 'Chi nhánh Văn Phòng Phẩm Quận 3',
      'latitude': 10.7843,
      'longitude': 106.6682,
      'address': '456 Đường XYZ, Quận 3, TP.HCM'
    },
  ];

  Set<Marker> _createMarkers() {
    return shopLocations.map((shop) {
      return Marker(
        markerId: MarkerId(shop['name']),
        position: LatLng(shop['latitude'], shop['longitude']),
        infoWindow: InfoWindow(
          title: shop['name'],
          snippet: shop['address'],
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Địa điểm cửa hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
              shopLocations[0]['latitude'], shopLocations[0]['longitude']),
          zoom: 12,
        ),
        markers: _createMarkers(),
        mapType: MapType.normal,
        compassEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
