import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import '../../data/models/models.dart';

class AllMembersScreen extends StatelessWidget {
  final Office office;
  final List<Member> members;
  final String leaderName;

  const AllMembersScreen({
    Key? key,
    required this.office,
    required this.members,
    required this.leaderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أعضاء ${office.title}'),
        centerTitle: true,
        actions: [
          if (leaderName.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showLeaderInfo(context),
            ),
        ],
      ),
      body: _buildMembersList(context),
    );
  }

  Widget _buildMembersList(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
        child: Text('لا يوجد أعضاء مسجلين بعد'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildMemberCard(context, members[index]),
    );
  }

  Widget _buildMemberCard(BuildContext context, Member member) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member.image != null && member.image!.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(member.image!),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                member.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الهاتف:', member.phone),
            _buildInfoRow('تاريخ الانضمام:', member.joinDate),
            if (member.identity.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('رقم الهوية:', member.identity),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.phone,
                  label: 'اتصال',
                  color: Colors.green,
                  onPressed: () => _launchUrl('tel:${member.phone}'),
                ),
                _buildActionButton(
                  icon: Icons.chat,
                  label: 'واتساب',
                  color: Colors.green,
                  onPressed: () => _launchUrl(member.whatsapp ?? ''),
                ),
                _buildActionButton(
                  icon: Icons.perm_identity,
                  label: 'بطاقة الناخب',
                  color: Colors.blue,
                  onPressed: () => _showIdentityDialog(context, member),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          color: color,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.2),
            padding: const EdgeInsets.all(12),
          ),
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _showIdentityDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('الهوية الشخصية'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (member.image != null && member.image!.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: PhotoView(
                        imageProvider: NetworkImage(member.image!),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        initialScale: PhotoViewComputedScale.contained,
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        loadingBuilder: (context, event) => Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                            ),
                          ),
                        ),
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('لا يوجد صورة متاحة للهوية'),
                    ),
                  const SizedBox(height: 16),
                  _buildIdentityInfoRow('الاسم:', member.fullName),
                  _buildIdentityInfoRow('رقم الهوية:', member.identity),
                  _buildIdentityInfoRow('رقم الهاتف:', member.phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'غير متوفر',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaderInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات القائد'),
        content: Text(
          'قائد المكتب: $leaderName',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}