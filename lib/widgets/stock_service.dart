import 'dart:convert';

import 'package:http/http.dart' as http;

void main() {
  StockService stockService = StockService();
  stockService.getAllStock();
}

class Stock {
  int id;
  String barcode;
  String productName;
  String description;
  String date;
  int quantity;

  Stock(
      {required this.id,
      required this.barcode,
      required this.productName,
      required this.description,
      required this.date,
      required this.quantity});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
        id: json['id'] ?? 0,
        barcode: json['productBarCode'] ?? "",
        productName: json['productName'] ?? "",
        description: json['description'] ?? "",
        date: json['date'] ?? "",
        quantity: json['quantity'] ?? 0);
  }
}

class StockService {
  Future<List<Stock>> getAllStock() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.13.55:9000/ok-stock-service/find-all-products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Stock> stockList =
            data.map((e) => Stock.fromJson(e)).toList();
        print(stockList.length);
        return stockList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
