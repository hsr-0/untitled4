import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:provider/provider.dart';
import 'package:untitled4/data/api/api_service.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = LatLng(24.7136, 46.6753); // الرياض
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final offices = await apiService.getOffices();
      final representations = await apiService.getRepresentations();

      setState(() {
        _addOfficeMarkers(offices);
        _addRepresentationMarkers(representations);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading map data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل بيانات الخريطة')),
      );
    }
  }

  void _addOfficeMarkers(List<Office> offices) {
    offices.asMap().forEach((index, office) {
      final markerId = MarkerId('office_${office.id}');
      final marker = Marker(
        markerId: markerId,
        position: LatLng(
          24.7136 + (index * 0.01), // إحداثيات عشوائية للتوضيح
          46.6753 + (index * 0.01),
        ),
        infoWindow: InfoWindow(
          title: office.title,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _markers.add(marker);
    });
  }

  void _addRepresentationMarkers(List<Representation> representations) {
    representations.asMap().forEach((index, rep) {
      final markerId = MarkerId('rep_${rep.id}');
      final marker = Marker(
        markerId: markerId,
        position: LatLng(
          24.7136 + (index * 0.015), // إحداثيات عشوائية للتوضيح
          46.6753 + (index * 0.015),
        ),
        infoWindow: InfoWindow(
          title: rep.title,
          snippet: 'المناطق: ${rep.regionsCount}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMapData,
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}