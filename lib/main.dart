import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gestiondedepance/app.dart';
import 'simple_bloc_observer.dart';

const String GEMINI_API_KEY = "AIzaSyCecBVytIXoAH5mqYjbOksiI7BZW_E12Q4";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Gemini.init(apiKey: GEMINI_API_KEY);
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
