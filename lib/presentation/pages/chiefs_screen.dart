import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled4/data/api/api_service.dart';
import 'package:untitled4/data/models/chief_model.dart';
import 'chiefdetails_screen.dart';

class ChiefsScreen extends StatefulWidget {
  @override
  _ChiefsScreenState createState() => _ChiefsScreenState();
}

class _ChiefsScreenState extends State<ChiefsScreen> {
  List<Chief> _chiefs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadChiefs();
  }

  Future<void> _loadChiefs({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newChiefs = await Provider.of<ApiService>(context, listen: false)
          .getChiefs(page: _currentPage);

      setState(() {
        _isLoading = false;
        _hasMore = newChiefs.isNotEmpty;
        if (reset) {
          _chiefs = newChiefs;
        } else {
          _chiefs.addAll(newChiefs);
        }
        if (newChiefs.isNotEmpty) _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '⚠️ ${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  List<Chief> _filterChiefs() {
    if (_searchQuery.isEmpty) return _chiefs;

    return _chiefs.where((chief) {
      final query = _searchQuery.toLowerCase();
      return (chief.fullName.toLowerCase().contains(query)) ||
          (chief.phone.contains(_searchQuery)) ||
          (chief.title.toLowerCase().contains(query)) ||
          (chief.whatsapp?.contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredChiefs = _filterChiefs();

    return Scaffold(
      appBar: AppBar(


      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'ابحث بالاسم، الهاتف أو المنصب',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadChiefs(reset: true),
              child: _isLoading && _currentPage == 1
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : filteredChiefs.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _chiefs.isEmpty
                          ? Icons.group_off
                          : Icons.search_off,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _chiefs.isEmpty
                          ? 'لا يوجد زعماء مسجلين'
                          : 'لا توجد نتائج لـ "$_searchQuery"',
                      style: TextStyle(fontSize: 18),
                    ),
                    if (_searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                        child: Text('عرض الكل'),
                      ),
                  ],
                ),
              )
                  : NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (!_isLoading &&
                      _hasMore &&
                      scroll.metrics.pixels ==
                          scroll.metrics.maxScrollExtent) {
                    _loadChiefs();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: filteredChiefs.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredChiefs.length) {
                      return Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ));
                    }
                    return ChiefCard(chief: filteredChiefs[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChiefCard extends StatelessWidget {
  final Chief chief;

  const ChiefCard({Key? key, required this.chief}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChiefDetailsScreen(chief: chief),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              if (chief.imageUrl != null && chief.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    chief.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.person, size: 50),
                  ),
                )
              else
                CircleAvatar(
                  radius: 35,
                  child: Icon(Icons.person, size: 30),
                ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chief.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (chief.title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          chief.title,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 16),
                          SizedBox(width: 4),
                          Text(chief.phone),
                        ],
                      ),
                    ),
                    if (chief.whatsapp != null && chief.whatsapp!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(chief.whatsapp!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}