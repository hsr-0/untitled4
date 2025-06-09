import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class StatsWidget extends StatelessWidget {
  final int totalMembers;
  final int officeCount;
  final int representationCount;
  final int chiefsCount;
  final int votersCount;

  const StatsWidget({
    Key? key,
    required this.totalMembers,
    required this.officeCount,
    required this.representationCount,
    required this.chiefsCount,
    required this.votersCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 3),
      badgeContent: Text(
        '$totalMembers',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      child: IconButton(
        icon: Icon(Icons.analytics),
        onPressed: () {
          _showStatsDialog(context);
        },
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إحصائيات النظام'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem(Icons.business, 'عدد المكاتب', officeCount),
            _buildStatItem(Icons.account_balance, 'عدد الممثليات', representationCount),
            _buildStatItem(Icons.people, 'إجمالي الأعضاء', totalMembers),
            _buildStatItem(Icons.person, 'عدد الزعماء', chiefsCount),
            _buildStatItem(Icons.how_to_vote, 'عدد الناخبين', votersCount),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, int value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Text('$value'),
        ],
      ),
    );
  }
}