import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:untitled4/presentation/pages/all_members_screen.dart';

class LeaderCard extends StatelessWidget {
  final Leader leader;
  final Office office;
  final VoidCallback? onPressed;

  const LeaderCard({
    Key? key,
    required this.leader,
    required this.office,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leader Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeaderAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leader.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (leader.title != null && leader.title!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              leader.title!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'عدد الأعضاء: ${leader.membersCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Contact Buttons
              Row(
                children: [
                  if (leader.whatsapp != null && leader.whatsapp!.isNotEmpty)
                    Expanded(
                      child: _buildContactButton(
                        context,
                        icon: Icons.chat,
                        label: 'واتساب',
                        color: Colors.green,
                        onPressed: () => _launchWhatsApp(context, leader.whatsapp!),
                        phone: leader.whatsapp!,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildContactButton(
                      context,
                      icon: Icons.phone,
                      label: 'اتصال',
                      color: Colors.blue,
                      onPressed: () => _launchPhoneCall(context, leader.phone),
                      phone: leader.phone,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _navigateToMembersScreen(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'عرض تفاصيل الأعضاء',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMembersScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllMembersScreen(
          office: office,
          members: leader.members,
          leaderName: leader.fullName,
        ),
      ),
    );
  }

  Widget _buildLeaderAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.blue.shade700,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: leader.image != null && leader.image!.isNotEmpty
            ? Image.network(
          leader.image!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildContactButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
        required String phone,
      }) {
    final isValid = phone.isNotEmpty;

    return ElevatedButton(
      onPressed: isValid ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isValid ? color : Colors.grey.shade400,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
          if (!isValid) const Icon(Icons.warning_amber, size: 14),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    try {
      // إذا كان الرابط يحتوي على URL كامل
      if (phone.startsWith('http')) {
        if (await canLaunchUrl(Uri.parse(phone))) {
          await launchUrl(Uri.parse(phone));
          return;
        }
      }

      // تنظيف الرقم من أي أحرف غير رقمية
      final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      // إنشاء رابط الواتساب
      final url = 'https://wa.me/$cleanedPhone';
      debugPrint('Opening WhatsApp with URL: $url');

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'تطبيق الواتساب غير مثبت';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ الواتساب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchPhoneCall(BuildContext context, String phone) async {
    try {
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('رقم الهاتف غير متوفر')),
        );
        return;
      }

      // تنظيف الرقم من أي أحرف غير رقمية
      final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      debugPrint('Cleaned phone number: $cleanedPhone');

      // إنشاء رابط الاتصال
      final url = 'tel:$cleanedPhone';
      debugPrint('Calling URL: $url');

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'تعذر فتح تطبيق الهاتف';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاتصال: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Phone call error details: $e');
    }
  }
}