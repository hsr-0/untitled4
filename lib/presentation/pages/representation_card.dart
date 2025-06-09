import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:untitled4/presentation/pages/regions_screen.dart';

class RepresentationCard extends StatelessWidget {
  final Representation representation;
  final VoidCallback? onPressed;

  const RepresentationCard({
    super.key,
    required this.representation,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final hasWhatsApp = representation.leader.whatsapp?.isNotEmpty ?? false;
    final hasPhone = representation.leader.phone?.isNotEmpty ?? false;
    final hasRegions = representation.regions.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context, theme),

              const Divider(height: 16, thickness: 1),

              // Leader Info Section
              _buildLeaderInfoSection(theme),

              if (representation.office != null) ...[
                const SizedBox(height: 8),
                _buildOfficeInfoSection(theme),
              ],

              if (hasWhatsApp || hasPhone) ...[
                const SizedBox(height: 8),
                _buildContactButtons(context),
              ],

              if (hasRegions) ...[
                const SizedBox(height: 8),
                _buildRegionsButton(context, theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'representation-avatar-${representation.id}',
          child: _buildRepresentationAvatar(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                representation.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      representation.location,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'المناطق التابعة: ${representation.regions.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات الممثلية', theme),
        _buildInfoRow(
          label: 'الاسم',
          value: representation.leader.name ?? 'غير معروف',
          theme: theme,
        ),
        _buildInfoRow(
          label: 'المنصب',
          value: representation.leader.title ?? 'غير محدد',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildOfficeInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('المكتب التابع', theme),
        _buildInfoRow(
          label: 'الاسم',
          value: representation.office?.title ?? 'غير معروف',
          theme: theme,
        ),
        _buildInfoRow(
          label: 'الموقع',
          value: representation.office?.location ?? 'غير محدد',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildContactButtons(BuildContext context) {
    final hasWhatsApp = representation.leader.whatsapp?.isNotEmpty ?? false;
    final hasPhone = representation.leader.phone?.isNotEmpty ?? false;

    return Row(
      children: [
        if (hasWhatsApp)
          Expanded(
            child: _buildContactButton(
              context,
              icon: Icons.chat_outlined,
              label: 'واتساب',
              color: Colors.green,
              onPressed: () => _launchWhatsApp(context, representation.leader.whatsapp!),
              phone: representation.leader.whatsapp!,
            ),
          ),
        if (hasWhatsApp && hasPhone) const SizedBox(width: 8),
        if (hasPhone)
          Expanded(
            child: _buildContactButton(
              context,
              icon: Icons.phone_outlined,
              label: 'اتصال',
              color: Colors.blue,
              onPressed: () => _launchPhoneCall(context, representation.leader.phone!),
              phone: representation.leader.phone!,
            ),
          ),
      ],
    );
  }

  Widget _buildRegionsButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: () => _navigateToRegionsScreen(context),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'عرض المناطق (${representation.regions.length})',
          style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildRepresentationAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: representation.leader.image?.isNotEmpty == true
            ? Image.network(
          representation.leader.image!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildDefaultAvatar();
          },
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 24,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
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
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: isValid ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isValid ? color : Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        minimumSize: const Size(0, 36),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
          ),
          if (!isValid)
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Icon(Icons.warning_amber_rounded, size: 14),
            ),
        ],
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

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    try {
      // إذا كان الرابط يحتوي على واتساب مباشر
      if (phone.startsWith('http') || phone.startsWith('https')) {
        await _launchUrl(context, phone);
        return;
      }

      // تنظيف الرقم من أي أحرف غير رقمية
      final cleanedPhone = _cleanPhoneNumber(phone);
      if (cleanedPhone.isEmpty) throw 'رقم الهاتف غير صالح';

      // إضافة رمز الدولة العراقي (964) إذا لم يكن موجوداً
      String whatsAppPhone;

      if (cleanedPhone.startsWith('0')) {
        // إذا بدأ بـ 0 نستبدله بـ 964
        whatsAppPhone = '964${cleanedPhone.substring(1)}';
      } else if (cleanedPhone.startsWith('+964')) {
        // إذا كان يحتوي على +964 نزيل علامة +
        whatsAppPhone = cleanedPhone.substring(1);
      } else if (cleanedPhone.startsWith('964')) {
        // إذا كان يحتوي على 964 بدون +
        whatsAppPhone = cleanedPhone;
      } else if (cleanedPhone.length >= 9) {
        // إذا كان الرقم بدون رمز دولة ونعتبره رقم عراقي
        whatsAppPhone = '964$cleanedPhone';
      } else {
        throw 'رقم الهاتف غير صالح';
      }

      // إزالة أي أصفار زائدة بعد رمز الدولة
      whatsAppPhone = whatsAppPhone.replaceAll(RegExp(r'^9640+'), '964');

      final url = 'https://wa.me/$whatsAppPhone';
      await _launchUrl(context, url);
    } catch (e) {
      _showErrorSnackBar(context, 'فتح واتساب', e.toString());
    }
  }

  Future<void> _launchPhoneCall(BuildContext context, String phone) async {
    try {
      final cleanedPhone = _cleanPhoneNumber(phone);
      if (cleanedPhone.isEmpty) throw 'رقم الهاتف غير صالح';

      // معالجة رقم الهاتف للاتصال
      String callPhone;

      if (cleanedPhone.startsWith('0')) {
        callPhone = '+964${cleanedPhone.substring(1)}';
      } else if (cleanedPhone.startsWith('964')) {
        callPhone = '+$cleanedPhone';
      } else if (!cleanedPhone.startsWith('+')) {
        callPhone = '+$cleanedPhone';
      } else {
        callPhone = cleanedPhone;
      }

      final telUrl = 'tel:$callPhone';
      await _launchUrl(context, telUrl);
    } catch (e) {
      _showErrorSnackBar(context, 'إجراء المكالمة', e.toString());
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) throw 'رابط غير صالح';

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'تعذر فتح التطبيق';
    }
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  bool _isValidPhoneNumber(String phone, {bool isWhatsApp = false}) {
    if (phone.isEmpty) return false;
    if (phone.startsWith('http') || phone.startsWith('https')) return true;

    final cleaned = _cleanPhoneNumber(phone);
    if (cleaned.isEmpty) return false;

    if (isWhatsApp) {
      return RegExp(r'^(\+|0|00)[0-9]{9,15}$').hasMatch(cleaned);
    }

    return RegExp(r'^(\+|0|00)[0-9]{6,15}$').hasMatch(cleaned);
  }

  void _showErrorSnackBar(BuildContext context, String action, String error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ في $action: $error'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}