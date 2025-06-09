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
    final isValid = _isValidPhoneNumber(phone, isWhatsApp: label == 'واتساب');

    return ElevatedButton(
      onPressed: isValid ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isValid ? color : Colors.grey,
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
          if (!isValid) const Icon(Icons.warning, size: 14),
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

      String cleanedPhone = _cleanPhoneNumber(phone);

      // معالجة الأرقام العراقية
      if (cleanedPhone.startsWith('0')) {
        cleanedPhone = '964${cleanedPhone.substring(1)}'; // تحويل 077 إلى 96477
      } else if (!cleanedPhone.startsWith('964')) {
        cleanedPhone = '964$cleanedPhone';
      }

      // التأكد من طول الرقم (964 + 9 خانات = 12)
      if (cleanedPhone.length != 12) {
        throw 'رقم الواتساب يجب أن يتكون من 12 رقماً (بما في ذلك 964)';
      }

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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _launchPhoneCall(BuildContext context, String phone) async {
    try {
      String cleanedPhone = _cleanPhoneNumber(phone);

      // إضافة 0 إذا كان الرقم 9 خانات (للاتصال المحلي)
      if (cleanedPhone.length == 9 && !cleanedPhone.startsWith('0')) {
        cleanedPhone = '0$cleanedPhone';
      }

      // التحقق من صحة الرقم العراقي (يبدأ بـ 07 أو 08 أو 09 و 10 خانات)
      if (!RegExp(r'^0[7-9]\d{8}$').hasMatch(cleanedPhone)) {
        throw 'رقم الهاتف العراقي يجب أن يبدأ بـ 07/08/09 ويتكون من 10 خانات';
      }

      final url = 'tel:$cleanedPhone';
      debugPrint('Making call to: $url');

      // محاولة بديلة إذا فشلت المحاولة الأولى
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // محاولة باستخدام tel:// بدلاً من tel:
        final altUrl = 'tel://$cleanedPhone';
        if (await canLaunchUrl(Uri.parse(altUrl))) {
          await launchUrl(Uri.parse(altUrl));
        } else {
          throw 'تعذر فتح تطبيق الهاتف. تأكد من الصلاحيات';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ الاتصال: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('Phone call error details: $e');
    }
  }

  String _cleanPhoneNumber(String phone) {
    // إزالة جميع المسافات والأحرف غير الرقمية
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool _isValidPhoneNumber(String phone, {bool isWhatsApp = false}) {
    if (phone.startsWith('http')) return true;

    final cleaned = _cleanPhoneNumber(phone);

    if (isWhatsApp) {
      return cleaned.length >= 10; // 964 + 9 خانات
    } else {
      return RegExp(r'^0[7-9]\d{8}$').hasMatch(cleaned); // 10 خانات تبدأ بـ 07/08/09
    }
  }
}