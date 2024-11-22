import 'package:flutter/material.dart';
import 'package:panda_flix/screens/home_screen.dart';
import 'package:panda_flix/screens/login_screen.dart';
import 'package:panda_flix/screens/movie_detail_screen.dart';
import 'package:panda_flix/screens/register_screen.dart';
import 'package:panda_flix/screens/favorites_screen.dart';
import 'package:panda_flix/screens/search_screen.dart';
import 'package:panda_flix/screens/watchlist_screen.dart';
import 'package:panda_flix/providers/auth_providers.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/search': (context) => SearchScreen(),
          '/movie-detail': (context) => MovieDetailsScreen(  id: ModalRoute.of(context)!.settings.arguments as int,
      isMovie: ModalRoute.of(context)!.settings.arguments as bool,),
          '/favorites': (context) => FavoritesScreen(),
          '/watchlist': (context) => WatchlistScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show HomeScreen if the user is logged in, else LoginScreen
    return authProvider.isLoggedIn ? HomeScreen() : LoginScreen();
  }
}
