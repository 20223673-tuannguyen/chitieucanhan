import 'package:btl/app/cubit/themeCubit.dart';
import 'package:btl/features/Account/cubit/manageMoneyCubit.dart';
import 'package:btl/features/Users/Cubit/userCubit.dart';
import 'package:btl/features/notification/cubit/notificationCubit.dart';
import 'package:btl/myApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // 1. Khởi tạo Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Hive để lưu cài đặt
  await Hive.initFlutter();
  await Hive.openBox('settings');
  // Mở thêm các box khác nếu bạn có (ví dụ: userBox, transactionBox...)
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => ManageMoneyCubit()),
        BlocProvider(create: (context) => NotificationCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi của ThemeCubit để cập nhật giao diện toàn app
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Quản lý chi tiêu',
          debugShowCheckedModeBanner: false,
          themeMode: state.themeMode,
          locale: state.lang,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: state.color ?? Colors.blue,
              brightness: Brightness.light,
            ),
            fontFamily: state.fontFamily,
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontSize: state.fontSize),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: state.color ?? Colors.blue,
              brightness: Brightness.dark,
            ),
            fontFamily: state.fontFamily,
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontSize: state.fontSize),
            ),
          ),
          home: const ExpenseTrackerScreen(),
        );
      },
    );
  }
}
