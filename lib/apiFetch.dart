import 'dart:convert';

import 'package:flutter/services.dart';

class QuranApi {
  late List<dynamic> ayahs = [];
  late Set<dynamic> pageAyah = {};
  late List<dynamic> pageNum = [];

  Future<Set<dynamic>> fetchData() async {
    String result =
        await rootBundle.loadString("assets/api/hafsData_v2-0.json");
    if (result.isNotEmpty) {
      ayahs = jsonDecode(result);
      for (var i = 0; i < ayahs.length; i++) {
        pageAyah.add(ayahs[i]['sura_name_ar']);
        pageNum.add(ayahs[i]['sura_name_ar']);
      }

      return pageAyah;
    }
    return Future.error('error');
  }
}
