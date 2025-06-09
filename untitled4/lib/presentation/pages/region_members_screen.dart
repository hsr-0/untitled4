import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegionMembersScreen extends StatelessWidget {
  final List<Region> regions;
  final String representationTitle;

  const RegionMembersScreen({
    Key? key,
    required this.regions,
    required this.representationTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مناطق $representationTitle'),
      ),
      body: regions.isEmpty
          ? const Center(child: Text('لا توجد مناطق متاحة'))
          : ListView.builder(
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (region.leader.name.isNotEmpty)
                    Text('القائد: ${region.leader.name}'),
                  if (region.leader.phone.isNotEmpty)
                    TextButton(
                      onPressed: () => _makePhoneCall(context, region.leader.phone),
                      child: Text('اتصال: ${region.leader.phone}'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
      final url = 'tel:$phoneNumber';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إجراء المكالمة: $e'),
        ),
      );
    }
  }
}