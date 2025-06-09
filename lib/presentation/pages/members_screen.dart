import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

class MembersScreen extends StatelessWidget {
  final String officeTitle;
  final List<Member> members;

  const MembersScreen({
    required this.officeTitle,
    required this.members,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أعضاء مكتب $officeTitle'),
      ),
      body: members.isEmpty
          ? Center(child: Text('لا يوجد أعضاء مسجلين'))
          : ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return _buildMemberCard(members[index]);
        },
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[100],
          ),
          child: Icon(
            Icons.person,
            color: Colors.blue[800],
          ),
        ),
        title: Text(
          member.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.phone),
            if (member.identity != null)
              Text(
                'بطاقة الناخب: ${member.identity}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.phone, color: Colors.blue),
              onPressed: () => _makePhoneCall(member.phone),
            ),
            if (member.identity != null)
              IconButton(
                icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                onPressed: () => _viewIdentity(member.identity!),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _viewIdentity(String identityUrl) async {
    if (await canLaunch(identityUrl)) {
      await launch(identityUrl);
    } else {
      throw 'Could not launch $identityUrl';
    }
  }
}