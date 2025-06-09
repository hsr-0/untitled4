import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled4/data/models/models.dart';

class OfficeDetailsScreen extends StatelessWidget {
  final Office office;

  const OfficeDetailsScreen({required this.office, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(office.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfficeHeader(context),
            const SizedBox(height: 24),
            _buildLeadersSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeHeader(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              office.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    office.location,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow('رئيس المكتب', office.leader.name, context),
        if (office.leader.title.isNotEmpty)
          _buildInfoRow('المسمى الوظيفي', office.leader.title, context),
        _buildContactButtons(context),
      ],
    );
  }

  Widget _buildContactButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (office.leader.whatsapp != null && office.leader.whatsapp!.isNotEmpty)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(context, office.leader.whatsapp!),
                icon: Icon(Icons.chat, size: 18),
                label: Text('واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (office.leader.whatsapp != null && office.leader.whatsapp!.isNotEmpty)
            const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchPhoneCall(context, office.leader.phone),
              icon: Icon(Icons.phone, size: 18),
              label: Text('اتصال'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رؤساء الأقسام والأعضاء',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: office.leaders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final leader = office.leaders[index];
            return _buildLeaderCard(leader, context);
          },
        ),
      ],
    );
  }

  Widget _buildLeaderCard(Leader leader, BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: leader.image != null
                      ? ClipOval(
                    child: Image.network(
                      leader.image!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(Icons.person, size: 24, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leader.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (leader.title != null && leader.title!.isNotEmpty)
                        Text(
                          leader.title!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${leader.membersCount} أعضاء'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLeaderContactInfo(leader, context),
            if (leader.members.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMembersSection(leader, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderContactInfo(Leader leader, BuildContext context) {
    return Column(
      children: [
        _buildInfoRow('الهاتف', leader.phone, context),
        if (leader.whatsapp != null && leader.whatsapp!.isNotEmpty)
          _buildInfoRow('الواتساب', leader.whatsapp!, context),
        const SizedBox(height: 8),
        _buildLeaderContactButtons(leader, context),
      ],
    );
  }

  Widget _buildLeaderContactButtons(Leader leader, BuildContext context) {
    return Row(
      children: [
        if (leader.whatsapp != null && leader.whatsapp!.isNotEmpty)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _launchWhatsApp(context, leader.whatsapp!),
              icon: Icon(Icons.chat, size: 18),
              label: Text('واتساب'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        if (leader.whatsapp != null && leader.whatsapp!.isNotEmpty)
          const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _launchPhoneCall(context, leader.phone),
            icon: Icon(Icons.phone, size: 18),
            label: Text('اتصال'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(Leader leader, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأعضاء',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: leader.members.length,
          itemBuilder: (context, index) {
            final member = leader.members[index];
            return _buildMemberItem(member, context);
          },
        ),
      ],
    );
  }

  Widget _buildMemberItem(Member member, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (member.identity.isNotEmpty)
                  Text(
                    member.identity,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, size: 20, color: Colors.blue),
            onPressed: () => _launchPhoneCall(context, member.phone),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إجراء المكالمة: ${e.toString()}')),
      );
    }
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}