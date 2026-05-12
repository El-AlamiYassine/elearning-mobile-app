import 'package:elearning/features/student/screens/student_cours.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home/screens/home_screen.dart';
import 'core/constants/route.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/student/screens/student_dashboard.dart';
import 'features/teacher/screens/teacher_dashboard.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/student/providers/student_provider.dart';
import 'features/student/screens/explorer_screen.dart';

class ElearningApp extends StatelessWidget {
  const ElearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'E-Learning App',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const HomeScreen(),
            initialRoute: AppRoutes.home,
            routes: {
              AppRoutes.home: (context) => const HomeScreen(),

              AppRoutes.login: (context) => const LoginScreen(),

              AppRoutes.register: (context) => const RegisterScreen(),

              AppRoutes.studentDashboard: (context) => const StudentDashboard(),

              AppRoutes.teacherDashboard: (context) => const TeacherDashboard(),

              AppRoutes.adminDashboard: (context) => const AdminDashboard(),

              AppRoutes.studentCourses: (context) => const StudentCoursPage(),
              
              AppRoutes.explorer: (context) => const ExplorerScreen(),
            },
          );
        },
      ),
    );
  }
}
