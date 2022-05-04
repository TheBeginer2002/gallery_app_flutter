import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'screens/libary-screen.dart';

void main() => runApp(const PhotoApp());

class PhotoApp extends StatelessWidget {
  const PhotoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        fontFamily: 'Roboto');
    return OKToast(
      child: MaterialApp(
        title: 'Photos App',
        theme: theme.copyWith(
            colorScheme:
                theme.colorScheme.copyWith(secondary: Colors.amberAccent)),
        home: const LibraryScreen(),
      ),
    );
  }
}
