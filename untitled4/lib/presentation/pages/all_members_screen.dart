import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';

class AllMembersScreen extends StatelessWidget {
  final Office office;
  final List<Member> members;

  const AllMembersScreen({
    Key? key,
    required this.office,
    required this.members, required String leaderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أعضاء ${office.title}'),
        centerTitle: true,
      ),
      body: _buildMembersList(),
    );
  }

  Widget _buildMembersList() {
    if (members.isEmpty) {
      return const Center(
        child: Text('لا يوجد أعضاء مسجلين بعد'),
      );
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(Member member) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('الهاتف:', member.phone),
            _buildInfoRow('الهوية:', member.identity),
            _buildInfoRow('تاريخ الانضمام:', member.joinDate),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}