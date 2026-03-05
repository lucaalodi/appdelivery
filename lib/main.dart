import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/cart.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final cart = Cart();
  await cart.init();

  runApp(ChangeNotifierProvider(create: (_) => cart, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFC0392B);
    const lightOrange = Color(0xFFFDECEA);
    const backgroundColor = Color(0xFFF7F7F7);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,

        // 🔥 POPPINS GLOBAL
        textTheme: GoogleFonts.poppinsTextTheme(),

        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primaryOrange,
          onPrimary: Colors.white,
          secondary: lightOrange,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),

        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(width: 2),
          ),
          labelStyle: TextStyle(color: Colors.black54),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, height: 1.2),
          unselectedLabelStyle: const TextStyle(fontSize: 10, height: 1.2),
        ),
      ),
      home: const HomePage(),
    );
  }
}
