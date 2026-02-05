import 'package:flutter/material.dart';
import 'state.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  runApp(const NathanApp());
}

class NathanApp extends StatelessWidget {
  const NathanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nathan',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
            primary: Colors.teal.shade300, secondary: Colors.orange.shade300),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme:
            const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), elevation: 0),
        cardColor: const Color(0xFF1A1A1A),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A1A1A)),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
