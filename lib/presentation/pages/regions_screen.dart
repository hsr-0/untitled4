import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

class RegionsScreen extends StatelessWidget {
  final Representation representation;

  const RegionsScreen({
    super.key,
    required this.representation,
  });

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanedNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف غير صالح')),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanedNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف غير صالح')),
      );
      return;
    }

    String url;
    if (cleanedNumber.startsWith('0')) {
      url = 'https://wa.me/964${cleanedNumber.substring(1)}';
    } else if (cleanedNumber.startsWith('+')) {
      url = 'https://wa.me/${cleanedNumber.substring(1)}';
    } else {
      url = 'https://wa.me/$cleanedNumber';
    }

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق واتساب')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    }
  }

  Widget _buildContactButtons(BuildContext context, String phone) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('اتصال'),
            onPressed: () => _makePhoneCall(context, phone),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('واتساب'),
            onPressed: () => _openWhatsApp(context, phone),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
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

          // التحقق من وجود بيانات اتصال صالحة
          final hasValidContact = leader.phone.isNotEmpty &&
              leader.phone != "5" &&
              leader.name != "غير محدد";

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
                  // اسم المنطقة
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
                    'المدير: ${leader.name}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),

                  // أزرار الاتصال أو رسالة عدم التوفر
                  if (hasValidContact)
                    _buildContactButtons(context, leader.phone)
                  else
                    Text(
                      'لا يوجد معلومات اتصال متاحة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
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