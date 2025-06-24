import 'dart:io' show HttpOverrides;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanphongpham/model/services/my_http_overrides.dart';
import 'package:vanphongpham/model/services/timkiemsp_service.dart';
import 'package:vanphongpham/view/product/TrangChu.dart';
import 'package:vanphongpham/viewmodel/trangChuViewModel.dart';

import 'model/services/Nguoidung_service.dart'
    show UserService, MyHttpOverrides;

void main() {
  HttpOverrides.global = MyHttpOverrides();
  UserService.overrideHttp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TrangChuViewModel()),
        ChangeNotifierProvider(create: (context) => SearchViewModel()),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, home: TrangChu()),
    );
  }
}
