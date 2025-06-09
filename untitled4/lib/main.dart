import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:untitled4/data/api/api_service.dart';
import 'package:untitled4/presentation/pages/main_screen.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService(client: http.Client())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام المكاتب والممثليات',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal',
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', 'AE'),
      ],
      locale: Locale('ar', 'AE'),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}