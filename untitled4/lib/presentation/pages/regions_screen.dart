import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

class RegionsScreen extends StatelessWidget {
  final Representation representation;

  const RegionsScreen({
    super.key,
    required this.representation,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    String url() {
      if (phoneNumber.startsWith('0')) {
        return 'https://wa.me/964${phoneNumber.substring(1)}';
      }
      return 'https://wa.me/$phoneNumber';
    }

    if (await canLaunchUrl(Uri.parse(url()))) {
      await launchUrl(Uri.parse(url()));
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('مناطق ${representation.title}'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: representation.regions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final region = representation.regions[index];
          final leader = region.leader;

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المدرسة
                  Text(
                    region.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // معلومات المدير
                  Text(
                    'المدير: ${leader.name != region.name ? leader.name : "غير محدد"}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),

                  // أزرار الاتصال
                  Row(
                    children: [
                      // زر الاتصال
                      if (leader.phone.isNotEmpty && leader.phone != "5")
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('اتصال'),
                            onPressed: () => _makePhoneCall(leader.phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                      if (leader.phone.isNotEmpty && leader.phone != "5")
                        const SizedBox(width: 8),

                      // زر واتساب
                      if (leader.phone.isNotEmpty && leader.phone != "5")
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('واتساب'),
                            onPressed: () => _openWhatsApp(leader.phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}