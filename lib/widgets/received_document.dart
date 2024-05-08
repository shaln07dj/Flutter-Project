import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/get_sign_records.dart';
import 'package:pauzible_app/Helper/get_sign_url.dart';
import 'package:pauzible_app/widgets/loading_widget.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceivedDocumentWidget extends StatefulWidget {
  const ReceivedDocumentWidget({super.key});

  @override
  _ReceivedDocumentWidgetState createState() => _ReceivedDocumentWidgetState();
}

class _ReceivedDocumentWidgetState extends State<ReceivedDocumentWidget> {
  final scrollController = ScrollController();
  var hasMore = true;

  bool isLoading = false;
  String? appId;
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  String? recordId;
  String loading = 'progress';
  dynamic result;
  var loaderText =
      "Fetching information from Pauzible's Secure, Encrypted data vaults...";

  final columnTitle = [
    'Received On',
    'Category',
    'Sub Category',
    'Description',
    'Signed On',
    'Status',
    'Document'
  ];

  final List<String> expectedFields = [
    'created_at',
    'category',
    'sub_category',
    'description',
    'updated_at',
    'status',
    'skyflow_id'
  ];

  final grid = <List<String>>[];
  final rowTitle = <String>[];

  var currentPage = 1;
  var nextPage;
  var rowPerPage = 25;

  bool isFirstCall = true;

  void handleLoading(status) {
    setState(() {
      loading = status;
    });
  }

  void filterData(String value, List<Map<String, dynamic>> data) {
    setState(() {
      filteredData =
          data.where((item) => item['fields']['status'] != value).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(handleLoading, currentPage);

    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        fetchData(handleLoading, nextPage);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void fetchData(Function(String status) handleLoading, var thisPage) async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      int offSetValue = (thisPage - 1) * rowPerPage;
      result = await getSignRecords(handleLoading, offSetValue);
      if (isFirstCall) {
        isFirstCall = false;
        if (result.isEmpty) {
          setState(() {
            hasMore = false;
            loading = "failed";
            isLoading = false;
          });
          return;
        }
      } else {
        if (result.isEmpty || result.length < 25) {
          setState(() {
            hasMore = false;
          });
        }
      }

      for (var record in result) {
        rowTitle.add("");
        var fields = record['fields'];
        if (fields != null) {
          for (var key in expectedFields) {
            if (!fields.containsKey(key)) {
              fields[key] = "";
            }
          }

          grid.add([
            formatDate(fields['created_at']),
            fields['category'] ?? "",
            fields['sub_category'] ?? "",
            fields['description'] ?? "",
            formatDate(fields['updated_at']),
            fields['status'] ?? "",
            fields['skyflow_id'] ?? "",
          ]);
        } else {
          grid.add(["", "", "", "", "", "", ""]);
        }
      }
      debugPrint("Grid of 3rd tab===>>> $grid");
      //storing into data for mobile view list builder
      data.addAll(List<Map<String, dynamic>>.from(result));

      setState(() {
        loading = "success";
        isLoading = false;
        nextPage = thisPage + 1;
        grid;
        data;
        filterData(filteredStringForSignedRecord, data);
      });
    } catch (error) {
      const snackBar = SnackBar(
          content: Text('Occur data loading error. Please try later'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('Loading error: $error');
    }
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      grid.clear();
      data.clear();
      rowTitle.clear();
    });

    fetchData(handleLoading, currentPage);
  }

  String formatDate(String timestamp) {
    if (timestamp == null || timestamp == "") {
      return "";
    }
    DateFormat customFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS Z');

    try {
      DateTime dateTime = customFormat.parse(timestamp);

      String formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(dateTime);

      return formattedDate;
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return isDesktop(context)
        ? Container(
            width: screenWidth * .94,
            height: screenHeight * .57,
            color: const Color(0xFFFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: screenWidth * 0.04, top: screenHeight * 0.015),
                  child: Text(
                    "Documents from Pauzible",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: screenWidth * 0.03, top: 6),
                    height: screenHeight * 0.50,
                    width: screenWidth * 0.88,
                    child: grid.isNotEmpty && loading == 'success'
                        ? Scaffold(
                            body: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  RefreshIndicator(
                                    onRefresh: refreshData,
                                    child: StickyHeadersTable(
                                      scrollControllers: ScrollControllers(
                                          verticalBodyController:
                                              scrollController),
                                      columnsLength: columnTitle.length,
                                      rowsLength: rowTitle.length,
                                      columnsTitleBuilder: (i) => Container(
                                        color: const Color(0xFF0E5EB6),
                                        child: SizedBox(
                                          width: screenWidth * 0.145,
                                          height: screenHeight * 0.06,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                columnTitle[i],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      rowsTitleBuilder: (i) => const SizedBox(
                                        height: 0,
                                        width: 0,
                                      ),
                                      contentCellBuilder: (j, i) {
                                        String cellValue = grid[i][j];

                                        if (j == 4) {
                                          String updatedAt = grid[i][4];
                                          cellValue = grid[i][5] == 'SIGNED'
                                              ? updatedAt
                                              : '';
                                        }

                                        if (j == 5) {
                                          return Container(
                                            color: i.isEven
                                                ? const Color.fromARGB(
                                                        255, 221, 221, 233)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  width: screenWidth * 0.07,
                                                  decoration: BoxDecoration(
                                                    color: cellValue == 'SIGNED'
                                                        ? const Color.fromARGB(
                                                            255, 58, 162, 62)
                                                        : cellValue ==
                                                                'TOBESIGNED'
                                                            ? const Color
                                                                .fromARGB(255,
                                                                237, 194, 37)
                                                            : Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  child: Text(
                                                    cellValue == 'TOBESIGNED'
                                                        ? "SIGN"
                                                        : cellValue,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    style: (cellValue ==
                                                                'SIGNED' ||
                                                            cellValue ==
                                                                'TOBESIGNED')
                                                        ? const TextStyle(
                                                            color: Colors.white)
                                                        : const TextStyle(
                                                            color:
                                                                Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        if (j == 6) {
                                          return Container(
                                            color: i.isEven
                                                ? const Color.fromARGB(
                                                        255, 221, 221, 233)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: InkWell(
                                                  child: RichText(
                                                    text: const TextSpan(
                                                      text: 'View',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    String url =
                                                        await getSignUrl(
                                                            grid[i][j]);

                                                    if (url.isNotEmpty) {
                                                      try {
                                                        debugPrint(
                                                            "Inside try of View received doc");
                                                        if (await canLaunchUrl(
                                                          Uri.parse(url),
                                                        )) {
                                                          debugPrint(
                                                              "Inside IF TRY - View received doc");
                                                          await launchUrl(
                                                              Uri.parse(url),
                                                              webOnlyWindowName:
                                                                  '_blank');
                                                        } else {
                                                          // Handle the case where the URL cannot be launched
                                                          debugPrint(
                                                              "Inside ELSE TRY of View received doc");
                                                        }
                                                      } catch (e) {
                                                        // Handle any errors during URL launch
                                                        debugPrint(
                                                            "Inside catch of View received doc");
                                                      }
                                                    } else {
                                                      // Handle the case where the URL is empty
                                                      debugPrint(
                                                          "Inside ELSE of View received doc");
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        return Container(
                                          color: i.isEven
                                              ? const Color.fromARGB(
                                                      255, 221, 221, 233)
                                                  .withOpacity(0.3)
                                              : Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                cellValue,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      cellAlignments:
                                          const CellAlignments.fixed(
                                        contentCellAlignment:
                                            Alignment.centerLeft,
                                        stickyColumnAlignment:
                                            Alignment.topLeft,
                                        stickyRowAlignment:
                                            Alignment.centerLeft,
                                        stickyLegendAlignment:
                                            Alignment.centerLeft,
                                      ),
                                      cellDimensions: CellDimensions.fixed(
                                        contentCellWidth: screenWidth * 0.124,
                                        contentCellHeight: screenHeight * 0.05,
                                        stickyLegendWidth: 0,
                                        stickyLegendHeight: 50,
                                      ),
                                      showVerticalScrollbar: false,
                                      showHorizontalScrollbar: false,
                                    ),
                                  ),
                                  isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          )
                        : loading == 'progress'
                            ? Container(
                                margin:
                                    EdgeInsets.only(top: screenHeight * 0.2),
                                child: Center(
                                    child: Column(children: [
                                  LoadingWidget(
                                    loadingText: loaderText,
                                  )
                                ])))
                            : loading == 'failed'
                                ? Container(
                                    margin: EdgeInsets.only(
                                        top: screenHeight * 0.13),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/MicrosoftTeams-image.png',
                                            width: 125,
                                          ),
                                          const Text(
                                            "No Records Found",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )),
              ],
            ),
          )
        : //Mobile View
        Container(
            margin: EdgeInsets.only(
              bottom: screenHeight * 0.03,
            ),
            width: screenWidth * 0.95,
            height: screenHeight * 0.8,
            color: const Color(0xFFFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.015,
                  ),
                  child: Text(
                    "Documents from Pauzible",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                      left: screenWidth * 0.03,
                      top: screenHeight * 0.03,
                    ),
                    height: screenHeight * 0.53,
                    width: screenWidth * 0.88,
                    child: data.isNotEmpty && loading == 'success'
                        ? Container(
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.02,
                              right: screenWidth * 0.02,
                              bottom: screenHeight * 0.02,
                            ),
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                var item = data[index];
                                bool isEven = index.isEven;

                                Color? backgroundColor = isEven
                                    ? const Color.fromARGB(255, 221, 221, 233)
                                        .withOpacity(0.3)
                                    : null;
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: screenHeight * 0.015,
                                  ),
                                  child: ExpansionTileCard(
                                    baseColor: backgroundColor,
                                    elevation: 4.0,
                                    leading: CircleAvatar(
                                        child: Text(
                                      (index + 1).toString(),
                                    )),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["fields"]["category"] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          item["fields"]["created_at"] != null
                                              ? formatDate(
                                                  item["fields"]["created_at"])
                                              : '',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.only(
                                        top: screenHeight * 0.02,
                                        bottom: screenHeight * 0.02,
                                        left: screenWidth * 0.03,
                                        right: screenWidth * 0.03),
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              children: [
                                                const Text("Sub Category: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  item["fields"]
                                                          ["sub_category"] ??
                                                      '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Description: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    item["fields"]
                                                            ["description"] ??
                                                        '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Signed On: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  item["fields"]["status"] ==
                                                              'SIGNED' &&
                                                          item["fields"][
                                                                  "updated_at"] !=
                                                              null
                                                      ? formatDate(
                                                          item["fields"]
                                                              ["updated_at"])
                                                      : '',
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Status: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.04),
                                                Container(
                                                  width: screenWidth * 0.24,
                                                  height: screenHeight * 0.03,
                                                  decoration: BoxDecoration(
                                                    color: item["fields"]
                                                                ["status"] ==
                                                            'SIGNED'
                                                        ? const Color.fromARGB(
                                                            255, 58, 162, 62)
                                                        : item["fields"][
                                                                    "status"] ==
                                                                'TOBESIGNED'
                                                            ? const Color
                                                                .fromARGB(255,
                                                                237, 194, 37)
                                                            : Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  child: Center(
                                                    child: item["fields"]
                                                                ["status"] ==
                                                            'SIGNED'
                                                        ? Text(
                                                            item["fields"]
                                                                ["status"],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : item["fields"][
                                                                    "status"] ==
                                                                'TOBESIGNED'
                                                            ? const Text(
                                                                "SIGN",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            : Text(
                                                                item["fields"][
                                                                        "status"] ??
                                                                    '',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Document: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.04),
                                                InkWell(
                                                  child: RichText(
                                                    text: const TextSpan(
                                                      text: 'View',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    String url =
                                                        await getSignUrl(
                                                            item["fields"]
                                                                ["skyflow_id"]);

                                                    if (url.isNotEmpty) {
                                                      try {
                                                        debugPrint(
                                                            "Inside try of View received doc");
                                                        // if (await canLaunchUrl(
                                                        //     Uri.parse(url))) {
                                                        debugPrint(
                                                            "Inside IF TRY - View received doc");
                                                        await launchUrl(
                                                            Uri.parse(url),
                                                            webOnlyWindowName:
                                                                '_blank');
                                                        // } else {
                                                        //   // Handle the case where the URL cannot be launched
                                                        //   debugPrint(
                                                        //       "Inside ELSE TRY of View received doc");
                                                        // }
                                                      } catch (e) {
                                                        // Handle any errors during URL launch
                                                        debugPrint(
                                                            "Inside catch of View received doc: $e");
                                                      }
                                                    } else {
                                                      // Handle the case where the URL is empty
                                                      debugPrint(
                                                          "Inside else of View received doc");
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.024,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : loading == 'progress'
                            ? Container(
                                margin:
                                    EdgeInsets.only(top: screenHeight * 0.2),
                                child: Center(
                                    child: Column(children: [
                                  LoadingWidget(
                                    loadingText: loaderText,
                                  )
                                ])))
                            : loading == 'failed'
                                ? Container(
                                    margin: EdgeInsets.only(
                                        top: screenHeight * 0.13),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/MicrosoftTeams-image.png',
                                            width: 125,
                                          ),
                                          const Text(
                                            "No Records Found",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )),
              ],
            ),
          );
  }
}
