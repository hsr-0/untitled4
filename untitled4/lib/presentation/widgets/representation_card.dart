import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';

class RepresentationCard extends StatelessWidget {
  final Representation representation;
  final VoidCallback onPressed;

  const RepresentationCard({
    Key? key,
    required this.representation,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: representation.leader.image != null
                        ? NetworkImage(representation.leader.image!)
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          representation.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          representation.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoRow('المدير:', representation.leader.name),
              _buildInfoRow('الهاتف:', representation.leader.phone),
              _buildInfoRow('الواتساب:', representation.leader.whatsapp),
              _buildInfoRow('عدد المناطق:', representation.regionsCount.toString()),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: onPressed,
                child: Text('عرض المناطق التابعة'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}