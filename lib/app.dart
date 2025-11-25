import 'package:flutter/material.dart';

import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';
import 'core/remote/supabase_auth_service.dart';

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

//Cloud and Online
import 'features/cloud/presentation/pages/cloud_quiz_list_page.dart';
import 'features/cloud/presentation/pages/cloud_quiz_detail_page.dart';
import 'features/cloud/presentation/pages/import_quiz_page.dart';
import 'features/onlinetest/presentation/pages/create_test_page.dart';
import 'features/onlinetest/presentation/pages/test_list_page.dart';
import 'features/onlinetest/presentation/pages/test_room_page.dart';
import 'features/documents/presentation/pages/document_list_page.dart';
import 'features/documents/presentation/pages/pdf_viewer_page.dart';

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

      initialRoute: '/',

      /// 固定路由（无参数的页面）
      routes: {
        '/': (_) => const HomePage(),
        '/mine': (_) => const MinePage(),

        // 本地 Quiz
        '/quizList': (_) => QuizListPage(quizDao: quizDao),
        '/quizEditor': (_) => QuizEditorPage(quizDao: quizDao),
        '/questionEditor': (_) => QuestionEditorPage(quizDao: quizDao),
        '/quizPreview': (_) => QuizPreviewPage(quizDao: quizDao),

        // Practice
        '/practiceSelect': (_) => PracticeSelectPage(quizDao: quizDao),
        '/records': (_) => RecordListPage(practiceDao: practiceDao, quizDao: quizDao),

        // Auth
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/resetPassword': (_) => const ResetPasswordPage(),
        '/userProfile': (_) => const UserProfilePage(),
        '/documents': (_) => const DocumentListPage(),

        // Online test
        '/createTest': (_) => const CreateTestPage(),
        '/testList': (_) => const TestListPage(),
        '/testRoom': (_) => TestRoomPage(quizDao: quizDao),

        // Cloud 固定页面（无参数）
        '/cloudQuizList': (_) => const CloudQuizListPage(),

        '/importQuiz': (_) => ImportQuizPage(quizDao: quizDao),
      },

      /// 动态路由（可接收参数的页面）
      onGenerateRoute: (settings) {
        // ========== Cloud Quiz Detail ==========
        if (settings.name == '/cloudQuizDetail') {
          final summary = settings.arguments as CloudQuizSummary;
          return MaterialPageRoute(
            builder: (_) => CloudQuizDetailPage(summary: summary),
          );
        }

        // ========== Practice Run ==========
        if (settings.name == '/practiceRun') {
          final args = settings.arguments;
          final parsedArgs = args is PracticeRunArgs
              ? args
              : PracticeRunArgs(quizId: args as String);
          return MaterialPageRoute(
            builder: (_) => PracticeRunPage(
              quizId: parsedArgs.quizId,
              testId: parsedArgs.testId,
              quizDao: quizDao,
              practiceDao: practiceDao,
            ),
          );
        }

        // ========== Record Detail ==========
        if (settings.name == '/recordDetail') {
          final runId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => RecordDetailPage(
              runId: runId,
              practiceDao: practiceDao,
              quizDao: quizDao,
            ),
          );
        }

        if (settings.name == '/pdfViewer') {
          final args = settings.arguments as PdfViewerArgs;
          return MaterialPageRoute(
            builder: (_) => PdfViewerPage(args: args),
          );
        }

        return null;
      },
    );
  }
}
