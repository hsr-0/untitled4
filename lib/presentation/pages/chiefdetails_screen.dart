import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled4/data/models/chief_model.dart';
import 'voter_card.dart';

class ChiefDetailsScreen extends StatefulWidget {
  final Chief chief;

  const ChiefDetailsScreen({Key? key, required this.chief}) : super(key: key);

  @override
  _ChiefDetailsScreenState createState() => _ChiefDetailsScreenState();
}

class _ChiefDetailsScreenState extends State<ChiefDetailsScreen> {
  late Future<List<Voter>> _votersFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _votersFuture = _loadVoters();
  }

  Future<List<Voter>> _loadVoters() async {
    if (widget.chief.voters != null && widget.chief.voters!.isNotEmpty) {
      return widget.chief.voters!;
    }

    setState(() => _isLoading = true);

    try {
      // استبدل هذا بطلب API الفعلي لجلب الناخبين
      final response = await http.get(
          Uri.parse('https://myselfe.beytei.com/wp-json/maktabat/v1/chief/${widget.chief.id}')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final voters = (data['data']['voters'] as List)
              .map((voter) => Voter.fromJson(voter))
              .toList();

          // تحديث عدد الناخبين إذا كان مختلفاً
          if (data['data']['voters_count'] != widget.chief.votersCount) {
            widget.chief.votersCount = int.parse(data['data']['voters_count'].toString());
          }

          return voters;
        }
      }
      throw Exception('Failed to load voters');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chief.fullName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChiefInfoCard(context),
            SizedBox(height: 20),
            _buildStatsCard(),
            SizedBox(height: 20),
            _buildVotersSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChiefInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.chief.imageUrl != null
                  ? NetworkImage(widget.chief.imageUrl!)
                  : null,
              child: widget.chief.imageUrl == null
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
            SizedBox(height: 16),
            Text(
              widget.chief.fullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.chief.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.phone,
                  label: 'اتصال',
                  onPressed: () => _launchUrl('tel:${widget.chief.phone}'),
                ),
                if (widget.chief.whatsapp != null)
                  _buildActionButton(
                    icon: Icons.chat,
                    label: 'واتساب',
                    onPressed: () => _launchUrl('https://wa.me/${widget.chief.whatsapp}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.people, color: Colors.blue),
              title: Text('عدد الناخبين'),
              trailing: Text(
                widget.chief.votersCount.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotersSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'الناخبون التابعون',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: _isLoading
                ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : null,
          ),
          FutureBuilder<List<Voter>>(
            future: _votersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'حدث خطأ في جلب الناخبين',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لا يوجد ناخبين مسجلين',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: snapshot.data!
                      .map((voter) => VoterCard(voter: voter))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}