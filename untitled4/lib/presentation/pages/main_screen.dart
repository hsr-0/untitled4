import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:untitled4/data/api/api_service.dart';
import 'package:untitled4/data/models/models.dart';
import 'package:untitled4/presentation/widgets/office_card.dart';
import 'package:untitled4/presentation/pages/representation_card.dart';
import 'package:untitled4/presentation/widgets/stats_widget.dart';
import 'package:untitled4/presentation/pages/members_screen.dart';
import 'package:untitled4/presentation/pages/regions_screen.dart';
import 'package:untitled4/presentation/pages/map_screen.dart';
import 'package:untitled4/presentation/pages/office_leaders_screen.dart'; // تمت الإضافة
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:untitled4/presentation/pages/regions_screen.dart';

import 'all_members_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _totalMembers = 0;
  int _totalOffices = 0;
  int _totalRepresentations = 0;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  late Future<List<Office>> _officesFuture;
  late Future<List<Representation>> _representationsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
    _testApiConnection();
  }

  Future<void> _testApiConnection() async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/offices');
      final response = await http.get(url);
      debugPrint('API Connection Test: ${response.statusCode}');
    } catch (e) {
      debugPrint('API Test Error: $e');
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _officesFuture = Provider.of<ApiService>(context, listen: false).getOffices();
      _representationsFuture = Provider.of<ApiService>(context, listen: false).getRepresentations();
    });

    try {
      final offices = await _officesFuture;
      final representations = await _representationsFuture;

      if (!mounted) return;
      setState(() {
        _totalOffices = offices.length;
        _totalRepresentations = representations.length;
        _totalMembers = offices.fold(0, (sum, office) => sum + office.totalMembers);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _getUserFriendlyError(e);
      });
      debugPrint('Error loading data: $e');
    }
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is http.ClientException) {
      return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت';
    }
    return 'حدث خطأ أثناء جلب البيانات. يرجى المحاولة لاحقاً';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام المكاتب والممثليات'),
        centerTitle: true,
        actions: [
          StatsWidget(
            totalMembers: _totalMembers,
            officeCount: _totalOffices,
            representationCount: _totalRepresentations,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'تحديث البيانات',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'المكاتب'),
            Tab(icon: Icon(Icons.account_balance), text: 'الممثليات'),
            Tab(icon: Icon(Icons.map), text: 'الخريطة'),
          ],
        ),
      ),
      body: _buildTabView(),
    );
  }

  Widget _buildTabView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOfficesTab(),
        _buildRepresentationsTab(),
        MapScreen(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficesTab() {
    return Column(
      children: [
        _buildSearchField('ابحث في المكاتب'),
        Expanded(
          child: FutureBuilder<List<Office>>(
            future: _officesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorWidget();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState('لا توجد مكاتب متاحة');
              }

              final offices = _filterOffices(snapshot.data!);

              if (offices.isEmpty) {
                return _buildEmptyState('لا توجد نتائج مطابقة للبحث');
              }

              return _buildOfficesList(offices);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRepresentationsTab() {
    return Column(
      children: [
        _buildSearchField('ابحث في الممثليات'),
        Expanded(
          child: FutureBuilder<List<Representation>>(
            future: _representationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorWidget();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState('لا توجد ممثليات متاحة');
              }

              final representations = _filterRepresentations(snapshot.data!);

              if (representations.isEmpty) {
                return _buildEmptyState('لا توجد نتائج مطابقة للبحث');
              }

              return _buildRepresentationsList(representations);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(String hint) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  List<Office> _filterOffices(List<Office> offices) {
    return offices.where((office) =>
    office.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        office.leader.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        office.location.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<Representation> _filterRepresentations(List<Representation> representations) {
    return representations.where((rep) =>
    rep.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        rep.leader.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        rep.location.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Widget _buildOfficesList(List<Office> offices) {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        itemCount: offices.length,
        itemBuilder: (context, index) {
          final office = offices[index];
          return OfficeCard(
            key: ValueKey(office.id),
            office: office,
            onPressed: () => _navigateToOfficeLeaders(context, office),
          );
        },
      ),
    );
  }

  Widget _buildRepresentationsList(List<Representation> representations) {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        itemCount: representations.length,
        itemBuilder: (context, index) {
          return RepresentationCard(
            key: ValueKey(representations[index].id),
            representation: representations[index],
            onPressed: () => _navigateToRegions(context, representations[index]),
          );
        },
      ),
    );
  }

  void _navigateToOfficeLeaders(BuildContext context, Office office) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfficeLeadersScreen(office: office),
      ),
    );
  }

  void _navigateToRegions(BuildContext context, Representation representation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegionsScreen(representation: representation),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

void _navigateToAllMembers(BuildContext context, Office office) {
  // جمع جميع الأعضاء من جميع القادة
  final allMembers = office.leaders.expand((leader) => leader.members).toList();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AllMembersScreen(
        office: office,
        members: allMembers, leaderName: '',
      ),
    ),
  );
}
