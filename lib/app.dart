import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';

// 页面
import 'package:quiz_master/features/main/presentation/pages/home_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_list_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_editor_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/question_editor_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_preview_page.dart';
import 'package:quiz_master/features/practice/presentation/pages/practice_select_page.dart';
import 'package:quiz_master/features/practice/presentation/pages/practice_run_page.dart';
import 'package:quiz_master/features/record/presentation/pages/record_list_page.dart';
import 'package:quiz_master/features/record/presentation/pages/record_detail_page.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建数据库实例与 DAO
    final db = AppDb();
    final quizDao = QuizDao(db);
    final practiceDao = PracticeDao(db);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Master',
      theme: ThemeData(primarySwatch: Colors.blue),

      // ✅ 设置默认主页为 HomePage
      initialRoute: '/',

      routes: {
        // 首页
        '/': (_) => const HomePage(),

        // Quiz 列表页
        '/quizList': (_) => QuizListPage(quizDao: quizDao),

        // Quiz 编辑页（新建 / 编辑）
        '/quizEditor': (_) => QuizEditorPage(quizDao: quizDao),

        // Question 编辑页
        '/questionEditor': (_) => QuestionEditorPage(quizDao: quizDao),

        // Quiz 预览页
        '/quizPreview': (_) => QuizPreviewPage(quizDao: quizDao),

        //Practice 选择页
        '/practiceSelect': (_) => PracticeSelectPage(quizDao: quizDao),

        //Practice 练习页
        '/practiceRun': (ctx) {
          final quizId = ModalRoute.of(ctx)!.settings.arguments as String;
          return PracticeRunPage(
            quizId: quizId,
            quizDao: quizDao,
            practiceDao: practiceDao,
          );
        },

        //Record 列表页
        '/records': (_) => RecordListPage(practiceDao: practiceDao, quizDao: quizDao),

        //Record 详情页
        '/recordDetail': (ctx) {
          final runId = ModalRoute.of(ctx)!.settings.arguments as String;
          return RecordDetailPage(
            runId: runId,
            practiceDao: practiceDao,
            quizDao: quizDao,
          );
        },
      },
    );
  }
}
