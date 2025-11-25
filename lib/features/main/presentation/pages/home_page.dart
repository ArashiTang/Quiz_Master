import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0=Home, 1=Test Room, 2=Mine

  // 轻量样式工具
  TextStyle get _title =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  TextStyle get _subtle => const TextStyle(color: Colors.black54);
  BorderRadius get _cardRadius => BorderRadius.circular(16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHero()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildQuickTiles(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildLocalQuizRow(context)),
            SliverToBoxAdapter(child: _buildCreateImportRow(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildCreateTestSection(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),

      // 底部导航
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) {
          setState(() => _tabIndex = i);

          // 这里根据按钮跳转页面
          if (i == 1) {
            Navigator.pushNamed(context, '/testRoom');
          } else if (i == 2) {
            // 进入 MinePage（你在 app.dart 里已经配过 '/mine'）
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

  // 顶部横幅
  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8FB2E0),
        borderRadius: _cardRadius,
      ),
      child: Row(
        children: [
          // Logo 预留
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

  // 三个功能砖块
  Widget _buildQuickTiles(BuildContext context) {
    Widget tile(IconData icon, String title, String subtitle,
        {VoidCallback? onTap, Color? color}) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 96,
            margin: const EdgeInsets.symmetric(horizontal: 8),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
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
      ),
    );
  }

  // Local Quiz 行
  Widget _buildLocalQuizRow(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  // Create / Import 两张卡
  Widget _buildCreateImportRow(BuildContext context) {
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
            margin: const EdgeInsets.only(left: 16, right: 8, top: 12),
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

  // Create Test 区域
  Widget _buildCreateTestSection(BuildContext context) {
    return Container(
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