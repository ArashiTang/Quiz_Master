import 'package:flutter/material.dart';
import 'package:quiz_master/core/widgets/adaptive_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0=Home, 1=Test Room, 2=Mine

  // Lightweight Style Tools
  TextStyle get _title =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  TextStyle get _subtle =>
      const TextStyle(fontSize: 12, color: Colors.black54);
  BorderRadius get _cardRadius => BorderRadius.circular(16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: AdaptiveLayout(
        builder: (context, layout) {
          final sectionGap = layout.gutter * 1.25;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHero(layout)),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap)),
                SliverToBoxAdapter(child: _buildQuickTiles(context, layout)),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap)),
                SliverToBoxAdapter(child: _buildLocalQuizRow(context, layout)),
                SliverToBoxAdapter(child: _buildCreateImportRow(context, layout)),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap)),
                SliverToBoxAdapter(child: _buildCreateTestSection(context, layout)),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap * 1.5)),
              ],
            ),
          );
        },
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) {
          setState(() => _tabIndex = i);

          // This page redirects based on the button.
          if (i == 1) {
            Navigator.pushNamed(context, '/testRoom');
          } else if (i == 2) {
            // Enter MinePage (you've already configured '/mine' in app.dart).
            Navigator.pushNamed(context, '/mine');
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Test Room'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Mine'),
        ],
      ),
    );
  }

  // Top banner
  Widget _buildHero(AdaptiveLayoutData layout) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: layout.gutter / 2),
      padding: EdgeInsets.all(layout.gutter * 1.1),
      decoration: BoxDecoration(
        color: const Color(0xFF8FB2E0),
        borderRadius: _cardRadius,
      ),
      child: Row(
        children: [
          // Logo reserved
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book,
                size: 40, color: Color(0xFF698CB9)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Master',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Focus on Quiz',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Three functional bricks
  Widget _buildQuickTiles(BuildContext context, AdaptiveLayoutData layout) {
    Widget tile(IconData icon, String title, String subtitle,
        {VoidCallback? onTap, Color? color}) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 96,
            margin: EdgeInsets.symmetric(horizontal: layout.gutter / 2),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey.shade200).withOpacity(.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.black54),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(Icons.article_outlined, 'My Record', '', onTap: () {
          Navigator.pushNamed(context, '/records');
        }, color: const Color(0xFFFFE5E5)),
        tile(Icons.edit_outlined, 'Go Practice', '', onTap: () {
          Navigator.pushNamed(context, '/practiceSelect');
        }, color: const Color(0xFFE9F5EA)),
        tile(Icons.cloud_outlined, 'My Cloud', '', onTap: () {
          Navigator.pushNamed(context, '/cloudQuizList');
        }, color: const Color(0xFFE7F0FF)),
      ],
    );
  }

  // Local Quiz
  Widget _buildLocalQuizRow(
      BuildContext context, AdaptiveLayoutData layout) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: layout.gutter * 0.75),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Local Quiz:',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('Manage your local Quiz',
            style: TextStyle(color: Colors.black45)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Enter', style: TextStyle(color: Colors.black54)),
            SizedBox(width: 4),
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/quizList');
        },
      ),
    );
  }

  // Create / Import Quiz
  Widget _buildCreateImportRow(
      BuildContext context, AdaptiveLayoutData layout) {
    Widget card({
      required String title,
      required String sub,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: _cardRadius,
          child: Container(
            height: 120,
            margin: EdgeInsets.symmetric(
              horizontal: layout.gutter / 2,
              vertical: layout.gutter,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _cardRadius,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: _title),
                      const SizedBox(height: 6),
                      Text(sub, style: _subtle),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black45),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        card(
          title: 'Create a new Quiz',
          sub: 'Easily create Quiz',
          onTap: () {
            Navigator.pushNamed(context, '/quizEditor', arguments: null);
          },
        ),
        card(
          title: 'Import Quiz',
          sub: "Efficiently import user's Quiz",
          onTap: () {
            Navigator.pushNamed(context, '/importQuiz', arguments: null);
          },
        ),
      ],
    );
  }

  // Create Test area
  Widget _buildCreateTestSection(
      BuildContext context, AdaptiveLayoutData layout) {
    return Container(
      margin: EdgeInsets.only(bottom: layout.gutter / 2),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: const Text('Create Test'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/createTest');
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Test Detail'),
            subtitle: const Text('get more detail of online test'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/testList');
            },
          ),
        ],
      ),
    );
  }
}