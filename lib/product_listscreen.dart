import 'dart:convert';
// import 'package:barcode/widgets/curved_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:stocktake/alertbox_screen.dart';
import 'package:stocktake/stocktakingItem.dart';
import 'package:stocktake/widgets/stock_service.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  String _scanBarcode = 'unknown';
  String? jsonString;
  String barcodeval = "";
  List<Stock> stockTakeList = [];
  List<Stock> stockTakeListtest = [];

  getStockList() async {
    try{
      stockTakeListtest.addAll(await StockService().getAllStock());
      setState(() {

      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getStockList();
    print(stockTakeListtest.length);
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) {
      setState(() {
        barcodeval = barcode;
      });
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException catch (e) {
      barcodeScanRes = 'Failed to get platform version. Error: $e';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(
        Uri.parse('http://10.0.13.55:9000/ok-stock-service/find-all-products'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  // Future<List<dynamic>> getStockListData() async {
  //   try {
  //     final url = Uri.parse(
  //         'http://10.0.13.55:9000/ok-stock-service/find-all-products');
  //     final response =
  //         await http.get(url, headers: {'Content-Type': 'application/json'});
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> jsonData = jsonDecode(response.body);
  //
  //       stockTakeList = jsonData['products'];
  //       print("Items in stock take List are----------- $stockTakeList");
  //       return stockTakeList;
  //     } else {
  //       // If the login fails, show an error dialog
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text('Error Occured Failed'),
  //           content: Text('Check your network connection'),
  //           actions: [
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () => Navigator.pop(context),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //
  //     return stockTakeList;
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Error Occured'),
  //         content: Text('Check your server for network :('),
  //         actions: [
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //   return stockTakeList;
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
// panapa whats hapenning wadedza getStockList Data
    //getStockListData();

    if (_scanBarcode != "unknown" && _scanBarcode != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => StockTakeScreen(barcode: _scanBarcode),
        ),
        (route) => false,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Product List View'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(context),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Stock'),
                    onTap: () {
                      startBarcodeScanStream();
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: ListView.builder(
                      itemCount: stockTakeListtest.length,
                      itemBuilder: (context, index) {
                        final stock = stockTakeListtest[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return MyAlertBox(
                                    quantity: stock.quantity,
                                    productName: stock.productName,
                                    date: stock.date,

                                  );
                                });
                          },
                          child: Container(
                            width: width * 0.7,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListTile(
                              title: Text("Product: ${stock.productName}"),
                              subtitle: Text(
                              'quantuty: ${stock.quantity}'),
                          ),
                          ),
                        );
                      },
                    ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scanBarcodeNormal();
        },
        foregroundColor: Colors.grey,
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.qr_code,
          size: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final BuildContext parentContext; // Define the parent context

  CustomSearchDelegate(
      this.parentContext); // Constructor to receive the context

  String barcodeResult = '';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        icon: Icon(Icons.qr_code_scanner),
        onPressed: () async {
          // Trigger barcode scan and update the query with the barcode result
          String result = await scanBarcode();
          query = result;
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Search suggestions for: $query'),
    );
  }

  Future<String> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color for the scan button
        'Cancel', // Text for the cancel button
        true, // Show flash icon
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        return barcodeScanRes;
      } else {
        return '';
      }
    } catch (e) {
      showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
          title: Text('Barcode Scanning Error'),
          content: Text('An error occurred while scanning the barcode.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return '';
    }
  }
}
