import 'package:flutter/material.dart';

import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';

// ===== 页面 =====

// 主功能
import 'package:quiz_master/features/main/presentation/pages/home_page.dart';
import 'package:quiz_master/features/main/presentation/pages/mine_page.dart';

// Quiz 本地编辑 & 预览
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_list_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_editor_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/question_editor_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_preview_page.dart';

// Practice
import 'package:quiz_master/features/practice/presentation/pages/practice_select_page.dart';
import 'package:quiz_master/features/practice/presentation/pages/practice_run_page.dart';

// Record
import 'package:quiz_master/features/record/presentation/pages/record_list_page.dart';
import 'package:quiz_master/features/record/presentation/pages/record_detail_page.dart';

// 账号相关
import 'features/account/presentation/pages/login_page.dart';
import 'features/account/presentation/pages/register_page.dart';
import 'features/account/presentation/pages/reset_password_page.dart';
import 'features/account/presentation/pages/user_profile_page.dart';
import 'features/account/presentation/pages/change_name_page.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建数据库实例与 DAO（整 app 复用同一实例）
    final db = AppDb();
    final quizDao = QuizDao(db);
    final practiceDao = PracticeDao(db);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Master',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),

      /// 默认入口：HomePage（里面有底部导航切到 Test Room / Mine）
      initialRoute: '/',

      routes: {
        // ===== 主导航 =====
        '/': (_) => const HomePage(),
        '/mine': (_) => const MinePage(), // 方便以后从别处跳到个人中心

        // ===== Quiz 本地编辑 =====
        '/quizList': (_) => QuizListPage(quizDao: quizDao),
        '/quizEditor': (_) => QuizEditorPage(quizDao: quizDao),
        '/questionEditor': (_) => QuestionEditorPage(quizDao: quizDao),
        '/quizPreview': (_) => QuizPreviewPage(quizDao: quizDao),

        // ===== Practice 自测 =====
        '/practiceSelect': (_) => PracticeSelectPage(quizDao: quizDao),
        '/practiceRun': (ctx) {
          final quizId = ModalRoute.of(ctx)!.settings.arguments as String;
          return PracticeRunPage(
            quizId: quizId,
            quizDao: quizDao,
            practiceDao: practiceDao,
          );
        },

        // ===== Record 记录 =====
        '/records': (_) =>
            RecordListPage(practiceDao: practiceDao, quizDao: quizDao),
        '/recordDetail': (ctx) {
          final runId = ModalRoute.of(ctx)!.settings.arguments as String;
          return RecordDetailPage(
            runId: runId,
            practiceDao: practiceDao,
            quizDao: quizDao,
          );
        },

        // ===== 账号 / Supabase Auth =====
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/resetPassword': (_) => const ResetPasswordPage(),
        '/userProfile': (_) => const UserProfilePage(),
      },
    );
  }
}