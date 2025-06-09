import 'package:flutter/material.dart';
import 'package:untitled4/data/models/models.dart';

import '../pages/leader_card.dart';

class OfficeLeadersScreen extends StatefulWidget {
  final Office office;

  const OfficeLeadersScreen({Key? key, required this.office}) : super(key: key);

  @override
  State<OfficeLeadersScreen> createState() => _OfficeLeadersScreenState();
}

class _OfficeLeadersScreenState extends State<OfficeLeadersScreen> {
  late List<Leader> _filteredLeaders;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredLeaders = widget.office.leaders;
    _searchController.addListener(_filterLeaders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLeaders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLeaders = widget.office.leaders.where((leader) {
        return leader.fullName.toLowerCase().contains(query) ||
            leader.phone.contains(query) ||
            (leader.title?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('رؤساء ${widget.office.title}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'ابحث عن رئيس بالاسم أو الرقم',
              leading: const Icon(Icons.search),
              backgroundColor: MaterialStateProperty.all(
                isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              elevation: MaterialStateProperty.all(1),
            ),
          ),

          // Leaders Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'عدد الرؤساء: ${_filteredLeaders.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Leaders List
          Expanded(
            child: _filteredLeaders.isEmpty
                ? Center(
              child: Text(
                'لا توجد نتائج',
                style: theme.textTheme.bodyLarge,
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredLeaders.length,
              itemBuilder: (context, index) {
                final leader = _filteredLeaders[index];
                return LeaderCard(
                  leader: leader,
                  office: widget.office,
                  onPressed: () {
                    // يمكنك إضافة شاشة تفاصيل القائد هنا إذا لزم الأمر
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}