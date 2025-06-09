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
import 'package:untitled4/presentation/pages/office_leaders_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:carousel_slider/carousel_slider.dart'; // لإضافة البنر القلاب

import 'all_members_screen.dart';
import 'chiefs_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _totalMembers = 0;
  int _totalOffices = 0;
  int _totalRepresentations = 0;
  int _totalChiefs = 0;
  int _currentBannerIndex = 0;
  int _totalVoters = 0; // إضافة هذا المتغير

  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  late Future<List<Office>> _officesFuture;
  late Future<List<Representation>> _representationsFuture;

  // قائمة صور البنر القلاب
  final List<String> _bannerImages = [
    'https://via.placeholder.com/800x400?text=بنر+1',
    'https://via.placeholder.com/800x400?text=بنر+2',
    'https://via.placeholder.com/800x400?text=بنر+3',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // زيادة طول التبويبات إلى 5
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
        title: const Text('خدمتي'),
        centerTitle: true,
        actions: [
          // إبقاء أيقونة إحصاءات النظام هنا
          StatsWidget(
            totalMembers: _totalMembers,
            officeCount: _totalOffices,
            representationCount: _totalRepresentations,
            chiefsCount: _totalChiefs, // يجب إضافته
            votersCount: _totalVoters, // يجب إضافته
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
            Tab(icon: Icon(Icons.home), text: 'الرئيسية'),

            Tab(icon: Icon(Icons.account_balance), text: 'الممثليات'),
            Tab(icon: Icon(Icons.map), text: 'الخريطة'),
            Tab(icon: Icon(Icons.people_alt), text: 'القادة'),
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
        _buildHomeTab(), // تبويب الرئيسية الجديد

        _buildRepresentationsTab(),
        MapScreen(),
        ChiefsScreen(),
      ],
    );
  }

  // تبويب الرئيسية الجديد
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // البنر القلاب
          _buildBannerSlider(),

          // إحصاءات النظام
          _buildStatsSection(),

          // قسم سريع للوصول إلى المكاتب (اختياري)
          _buildQuickAccessSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        CarouselSlider(
          items: _bannerImages.map((imageUrl) {
            return Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16/9,
            viewportFraction: 0.95,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _bannerImages.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == entry.key
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'إحصاءات النظام',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatItem(Icons.people, 'إجمالي الأعضاء', _totalMembers.toString()),
                _buildStatItem(Icons.business, 'عدد المكاتب', _totalOffices.toString()),
                _buildStatItem(Icons.account_balance, 'عدد الممثليات', _totalRepresentations.toString()),
                _buildStatItem(Icons.leaderboard, 'عدد القادة', _totalChiefs.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصول السريع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickAccessButton(
                Icons.business,
                'المكاتب',
                    () => _tabController.animateTo(1),
              ),
              _buildQuickAccessButton(
                Icons.account_balance,
                'الممثليات',
                    () => _tabController.animateTo(2),
              ),
              _buildQuickAccessButton(
                Icons.map,
                'الخريطة',
                    () => _tabController.animateTo(3),
              ),
              _buildQuickAccessButton(
                Icons.people_alt,
                'القادة',
                    () => _tabController.animateTo(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // باقي الدوال كما هي بدون تغيير
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