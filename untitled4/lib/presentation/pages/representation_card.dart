import 'package:flutter/material.dart';
import 'package:untitled4/presentation/pages/regions_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:untitled4/presentation/pages/region_members_screen.dart';

class RepresentationCard extends StatelessWidget {
  final Representation representation;
  final VoidCallback? onPressed;

  const RepresentationCard({
    Key? key,
    required this.representation,
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
              // Representation Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRepresentationAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          representation.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                representation.location,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'عدد المناطق: ${representation.regions.length}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Leader Info
              _buildSectionTitle('معلومات الممثل', theme),
              _buildInfoRow('الاسم', representation.leader.name, theme),
              if (representation.leader.title?.isNotEmpty ?? false)
                _buildInfoRow('المنصب', representation.leader.title!, theme),

              const SizedBox(height: 12),

              // Office Info
              _buildSectionTitle('المكتب التابع', theme),
              _buildInfoRow('اسم المكتب', representation.office!.title, theme),
              _buildInfoRow('موقع المكتب', representation.office!.location, theme),

              const SizedBox(height: 12),

              // Contact Buttons
              Row(
                children: [
                  if (representation.leader.whatsapp?.isNotEmpty ?? false)
                    Expanded(
                      child: _buildContactButton(
                        context,
                        icon: Icons.chat,
                        label: 'واتساب',
                        color: Colors.green,
                        onPressed: () => _launchWhatsApp(context, representation.leader.whatsapp!),
                        phone: representation.leader.whatsapp!,
                      ),
                    ),
                  if (representation.leader.whatsapp?.isNotEmpty ?? false) const SizedBox(width: 8),
                  if (representation.leader.phone?.isNotEmpty ?? false)
                    Expanded(
                      child: _buildContactButton(
                        context,
                        icon: Icons.phone,
                        label: 'اتصال',
                        color: Colors.blue,
                        onPressed: () => _launchPhoneCall(context, representation.leader.phone!),
                        phone: representation.leader.phone!,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Regions Button
              if (representation.regions.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _navigateToRegionsScreen(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'عرض المناطق التابعة (${representation.regions.length})',
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

  Future<void> _navigateToRegionsScreen(BuildContext context) async {
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegionsScreen(representation: representation),
      ),
    );
  }

  Widget _buildRepresentationAvatar() {
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
        child: representation.leader.image?.isNotEmpty == true
            ? Image.network(
          representation.leader.image!,
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
        Icons.account_balance,
        size: 30,
        color: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
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
      if (phone.startsWith('http')) {
        if (await canLaunchUrl(Uri.parse(phone))) {
          await launchUrl(Uri.parse(phone));
          return;
        }
      }

      String cleanedPhone = _cleanPhoneNumber(phone);

      if (cleanedPhone.startsWith('0')) {
        cleanedPhone = '964${cleanedPhone.substring(1)}';
      } else if (!cleanedPhone.startsWith('964')) {
        cleanedPhone = '964$cleanedPhone';
      }

      if (cleanedPhone.length != 12) {
        throw 'رقم الواتساب يجب أن يتكون من 12 رقماً';
      }

      final url = 'https://wa.me/$cleanedPhone';
      debugPrint('Opening WhatsApp with URL: $url');

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'تطبيق الواتساب غير مثبت';
      }
    } catch (e) {
      if (!context.mounted) return;
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

      if (cleanedPhone.length == 9 && !cleanedPhone.startsWith('0')) {
        cleanedPhone = '0$cleanedPhone';
      }

      if (!RegExp(r'^0[7-9]\d{8}$').hasMatch(cleanedPhone)) {
        throw 'رقم الهاتف يجب أن يبدأ بـ 07/08/09 ويتكون من 10 خانات';
      }

      final url = 'tel:$cleanedPhone';
      debugPrint('Making call to: $url');

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        final altUrl = 'tel://$cleanedPhone';
        if (await canLaunchUrl(Uri.parse(altUrl))) {
          await launchUrl(Uri.parse(altUrl));
        } else {
          throw 'تعذر فتح تطبيق الهاتف';
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ الاتصال: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool _isValidPhoneNumber(String phone, {bool isWhatsApp = false}) {
    if (phone.isEmpty) return false;
    if (phone.startsWith('http')) return true;

    final cleaned = _cleanPhoneNumber(phone);

    if (isWhatsApp) {
      return cleaned.length >= 10;
    } else {
      return RegExp(r'^0[7-9]\d{8}$').hasMatch(cleaned);
    }
  }
}