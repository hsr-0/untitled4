import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled4/data/models/models.dart';
import 'office_details_screen.dart';
import 'office_leaders_screen.dart'; // تأكد من استيراد شاشة القادة الجديدة

class OfficeCard extends StatelessWidget {
  final Office office;
  final VoidCallback? onPressed;

  const OfficeCard({
    required this.office,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed ?? () {
          // الانتقال إلى شاشة تفاصيل المكتب أو القادة حسب الحاجة
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfficeLeadersScreen(office: office),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Office Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'office-avatar-${office.id}',
                    child: _buildOfficeAvatar(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          office.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.blue.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                office.location,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Leader Info Section
              _buildSectionTitle('معلومات المكتب', theme),
              _buildInfoRow('الاسم', office.leader.name, theme),
              if (office.leader.title.isNotEmpty)
                _buildInfoRow('المنصب', office.leader.title, theme),
              _buildContactRow(
                context,
                phone: office.leader.phone,
                whatsapp: office.leader.whatsapp,
              ),

              const SizedBox(height: 16),

              // Statistics Section
              _buildSectionTitle('إحصائيات المكتب', theme),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    icon: Icons.people_alt_outlined,
                    value: office.leadersCount.toString(),
                    label: 'رؤساء الأعضاء',
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: Icons.group_outlined,
                    value: office.totalMembers.toString(),
                    label: 'الأعضاء',
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed ?? () {
                    // الانتقال إلى شاشة القادة عند الضغط
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfficeLeadersScreen(office: office),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('عرض الرؤساء والأعضاء'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeAvatar(BuildContext context) {
    final hasValidImage = office.thumbnail != null &&
        office.thumbnail!.isNotEmpty &&
        office.thumbnail!.toLowerCase() != 'false';

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasValidImage
            ? Image.network(
          office.thumbnail!,
          fit: BoxFit.cover,
          headers: const {"Accept": "image/*"},
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Failed to load office image: ${error.toString()}');
            return _buildDefaultAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.business_outlined,
        size: 32,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _buildContactRow(
      BuildContext context, {
        required String phone,
        required String? whatsapp,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'الاتصال',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (whatsapp != null && whatsapp.isNotEmpty)
                  _buildContactButton(
                    context,
                    icon: Icons.chat,
                    label: 'واتساب',
                    color: Colors.green,
                    onPressed: () => _launchWhatsApp(context, whatsapp),
                  ),
                _buildContactButton(
                  context,
                  icon: Icons.phone,
                  label: 'اتصال',
                  color: Colors.blue,
                  onPressed: () => _launchPhoneCall(context, phone),
                ),
              ],
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
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    try {
      final url = 'https://wa.me/${_cleanPhoneNumber(phone)}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح الواتساب: ${e.toString()}')),
      );
    }
  }

  Future<void> _launchPhoneCall(BuildContext context, String phone) async {
    try {
      final url = 'tel:${_cleanPhoneNumber(phone)}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Phone call error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إجراء المكالمة: ${e.toString()}')),
      );
    }
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}