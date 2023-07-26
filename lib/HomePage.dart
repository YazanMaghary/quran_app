// ignore_for_file: must_be_immutable, use_key_in_widget_constructors
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:quran_app/module/quran.dart';
import 'apiFetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as Quran;

class HomePage extends StatefulWidget {
  late int? getPagenumb;
  HomePage({this.getPagenumb});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuranModule quran = QuranModule();
  QuranApi api = QuranApi();
  late int pageNumber = 0;

  bool isLoading = true;
  Future<void> savePage(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("page", page);
    widget.getPagenumb = 0;
    print("Success");
  }

  Future<void> getPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // quran.QuranPages(prefs.getInt("page"));
    print("success");
    if (prefs.getInt("page") == null) {
      widget.getPagenumb = 0;
    } else {
      widget.getPagenumb = prefs.getInt("page");
    }
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> saveBookmark(int page) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt("bookmark", page);
  // }

  // Future<void> goToBookmark() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int? bookmarkedPage = prefs.getInt("bookmark");
  //   if (bookmarkedPage != null) {
  //     // If a bookmarked page exists, go to that page
  //     setState(() {
  //       pageNumber = bookmarkedPage;
  //     });
  //   }
  // }

  @override
  void initState() {
    getPage();
    api.fetchData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 126, 113, 82),
            title: const Text("Quran"),
            centerTitle: true,
            leading: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0, backgroundColor: Colors.transparent),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: SearchBar(),
                  );
                },
                child: const Icon(Icons.search)),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: Colors.transparent),
                  onPressed: () async {
                    SharedPreferences shared =
                        await SharedPreferences.getInstance();
                    shared.setInt("bookMark", pageNumber);
                  },
                  child: const Icon(Icons.bookmark_add)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: Colors.transparent),
                  onPressed: () async {
                    SharedPreferences shared =
                        await SharedPreferences.getInstance();
                    late int? save;
                    save = shared.getInt("bookMark");
                    // ignore: use_build_context_synchronously
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return HomePage(
                          getPagenumb: save! - 1,
                        );
                      },
                    ));
                  },
                  child: const Icon(Icons.bookmark)),
            ],
          ),
          body: widget.getPagenumb == null
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Color.fromARGB(255, 126, 113, 82),
                  ),
                )
              : PageView.builder(
                  controller: PageController(initialPage: widget.getPagenumb!),
                  reverse: true,
                  onPageChanged: (value) async {
                    await savePage(value);
                    setState(() {});
                  },
                  itemCount: 604,
                  itemBuilder: (context, index) {
                    pageNumber = index + 1;
                    return Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        index % 2 == 0
                            ? const Color(0xffd6c08e)
                            : const Color(0xffe5dabc),
                        index % 2 == 0
                            ? const Color(0xffe5dabc)
                            : const Color(0xffd6c08e)
                      ])),
                      child: Column(
                        children: [
                          Expanded(
                            child: PhotoView(
                              backgroundDecoration: const BoxDecoration(
                                  color: Colors.transparent),
                              imageProvider: AssetImage(
                                quran.QuranPages(pageNumber),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle),
                            width: 50,
                            height: 50,
                            child: Text(
                              ArabicNumbers().convert(pageNumber),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    );
                  })),
    );
  }
}

class SearchBar extends SearchDelegate {
  QuranApi q = QuranApi();
  Future<void> g() async {
    await q.fetchData();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(
          Icons.close,
          size: 14,
        ),
        splashRadius: 10,
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
      splashRadius: 20,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xffd6c08e), Color(0xffe5dabc)])),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 15,
            ),
            Text(
              query,
            ),
          ],
        ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    g();
    Set surah = q.pageAyah;
    List filter = surah.where((element) => element.contains(query)).toList();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          color: Colors.white,
          gradient:
              LinearGradient(colors: [Color(0xffd6c08e), Color(0xffe5dabc)])),
      child: ListView.builder(
          itemCount: query == '' ? surah.length : filter.length,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    print(Quran.getSurahPages(index + 1).first.toInt());
                    return HomePage(
                        getPagenumb: Quran.getSurahPages(index).first.toInt());
                  }));
                },
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      child: Text(
                          query == '' ? surah.elementAt(index) : filter[index],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ))),
                ));
          }),
    );
  }
}

// PageView.builder(
//             controller: PageController(initialPage: getPagenumb),
//             reverse: true,
//             onPageChanged: (value) async {
//               await savePage(value);
//               setState(() {});
//             },
//             itemCount: 603,
//             itemBuilder: (context, index) {
//               pageNumber = index + 1;
//               return Container(
//                 decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: [
//                   index % 2 == 0
//                       ? const Color(0xffd6c08e)
//                       : const Color(0xffe5dabc),
//                   index % 2 == 0
//                       ? const Color(0xffe5dabc)
//                       : const Color(0xffd6c08e)
//                 ])),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: PhotoView(
//                         backgroundDecoration:
//                             const BoxDecoration(color: Colors.transparent),
//                         imageProvider: AssetImage(
//                           quran.QuranPages(pageNumber),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       alignment: Alignment.center,
//                       decoration: const BoxDecoration(
//                           color: Colors.transparent, shape: BoxShape.circle),
//                       width: 50,
//                       height: 50,
//                       child: Text(
//                         ArabicNumbers().convert(pageNumber),
//                         style: const TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 16,
//                     ),
//                   ],
//                 ),
//               );
//             })