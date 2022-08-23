import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/features.dart';
import '../../models/myordersfields.dart';
import '../../providers/myorderitems.dart';
import '../../utils/prefUtils.dart';
import 'model.dart';
import '../../constants/IConstants.dart';

class RowHeader {
  static const String item = 'Item';
  static const String netPrice = 'Net.Price';
  static const String qty = 'Qty';
  static const String total = 'Total';
}

class gstDetails {
  String gstIndex;
  String taxableAmount;
  String cgst;
  String sgst;
  String total;
  gstDetails(
      {this.gstIndex = '',
      this.taxableAmount = '',
      this.cgst = '',
      this.sgst = '',
      this.total = ''});
}

class DeliveryDetails {
  String mobile = '';
  String email = '';
  String gstNo = '';
  String deliveryDate = '';
  String deliveryTime = '';
  String note = '';
  String orderDate = '';
  String paymentType = '';

  DeliveryDetails({
    this.mobile = '',
    this.email = '',
    this.gstNo = '',
    this.deliveryDate = '',
    this.deliveryTime = '',
    this.note = '',
    this.orderDate = '',
    this.paymentType = '',
  });
}

class PdfInvoiceService {
  final String? orderId;

  final orderItemData;
  final double subTotal;
  final double total;
  final String deliveryDateTime;
  final String paymentOption;
  final String totalSaving;
  final String mobile;
  final String email;
  PdfInvoiceService(
      {this.orderId,
      this.orderItemData,
      this.subTotal = 0,
      this.totalSaving = '',
      this.total = 0,
      this.deliveryDateTime = '',
      this.paymentOption = '',
      this.email = '',
      this.mobile = ''});

  pw.SizedBox setGstHeader(double width, String header) {
    return pw.SizedBox(
        width: width,
        child: pw.Text(header,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
  }

  Future<Uint8List> createInvoice() async {
    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(
                await rootBundle.load("assets/fonts/Lato-Regular.ttf")),
            bold: pw.Font.ttf(
                await rootBundle.load("assets/fonts/Lato-Bold.ttf"))));

    final String customerName = orderItemData.vieworder[0].customerName;
    final String customerAddress = orderItemData.vieworder[0].oaddress;

    final orderItems = orderItemData.vieworder1;

    final List<Product> elements = [
      const Product(
          RowHeader.item, RowHeader.netPrice, RowHeader.qty, RowHeader.total),
      for (var order in orderItems)
        Product(order.itemname, order.price, order.qty, order.subtotal)
    ];

    List<String> restaurantLocation =
        PrefUtils.prefs!.getString("restaurant_location")!.split(',');
    //print("rest location..."+restaurantLocation[0].toString() + "locarion.."+restaurantLocation.length.toString());

    final deliveryDetails = DeliveryDetails(
        mobile: mobile,
        email: email,
        gstNo: "",
        deliveryDate: deliveryDateTime.split(' ')[0],
        deliveryTime: deliveryDateTime.substring(12),
        note: "",
        orderDate: orderItemData.vieworder[0].odate, //"26-04-2022 at 11-43 PM",
        paymentType: paymentOption == 'cod'
            ? 'Cash On Delivery'
            : paymentOption); //"Cash On Delivery");

    final walletPayment = orderItemData.vieworder[0].wallet;
    final cashOnlinePayment = total.toString();

    /*final gst = gstDetails(
        gstIndex: '18',
        taxableAmount: '138.98',
        cgst: '12.5',
        sgst: '12.5',
        total: '164');*/

    final List<Product> totalElements = [
      Product("Sub Total", "", "",
          subTotal.toString() //"${getSubTotal(soldProducts)} EUR",
          ),
      Product("Delivery", "", "",
          double.parse(orderItemData.vieworder[0].itemodelcharge).toString()),
      if (orderItemData.vieworder[0].loyalty != 0)
        Product("Discount Applied(loyalty)", "", "",
            "-" + " " + (orderItemData.vieworder[0].loyalty).toString()),
      Product("Total", "", "", total.toString())
    ];

    final pdfFonts = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(
                await rootBundle.load("assets/fonts/Lato-Regular.ttf")),
            bold: pw.Font.ttf(
                await rootBundle.load("assets/fonts/Lato-Bold.ttf"))),
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (pw.Context context) {
          return [
            pw.Column(
              children: [
                pw.Column(
                  children: [
                    pw.Text(IConstants.APP_NAME.toUpperCase()),
                    pw.Text(orderId!),
                    pw.Text(orderItemData.vieworder[0].orderType == 'Delivery'
                        ? 'HOME Delivery'
                        : 'SELF PICKUP'),
                    pw.Text(restaurantLocation.length <=1?restaurantLocation[0].toString():restaurantLocation[restaurantLocation.length - 2].toString()),
                    pw.Text(restaurantLocation.last),
                    if (IConstants.gst.isNotEmpty || IConstants.gst != "0")
                      pw.Text(
                          "Gst No: ${IConstants.gst} "), //Yet to fix GST Number
                    pw.Text("Mobile : ${IConstants.primaryMobile}"),
                    pw.Text("Email : ${IConstants.primaryEmail}")
                  ],
                ),
                pw.Divider(),
                pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Bill to/Ship to:"),
                      pw.Text(
                          "Invoice Id: ${orderItemData.vieworder[0].invoice}"),
                      pw.Text(customerName),
                      pw.Text(customerAddress),
                      pw.SizedBox(height: 10),
                      pw.Text("Mobile : ${deliveryDetails.mobile}"),
                      pw.Text("Email : ${deliveryDetails.email}"),
                      //pw.Text("Gst No: ${deliveryDetails.gstNo}"),
                      pw.Text(
                          "Delivery Date : ${deliveryDetails.deliveryDate}"),
                      pw.Text(
                          "Delivery Time : ${deliveryDetails.deliveryTime}"),
                      pw.Text("Note : ${deliveryDetails.note}"),
                      pw.Text("Order Date : ${deliveryDetails.orderDate}"),
                      pw.Text("Payment Type : ${deliveryDetails.paymentType}")
                    ]),
                pw.Divider(),
                ...itemColumn(elements),
                ...itemColumn(totalElements),
                if (totalSaving != "00")
                  pw.Text("You Saved  ${IConstants.currencyFormat}$totalSaving",
                      style: pw.TextStyle(
                          fontBold: pdfFonts,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16)),
                pw.Text(
                    'Wallet Payment : $walletPayment | Cash/Online Payment : ${double.parse(cashOnlinePayment) - walletPayment}'),
                /*
          pw.Divider(),
              pw.Divider(),
               pw.Column(children: [
                pw.Row(children: [
                  setGstHeader(70, 'GST Index'),
                  setGstHeader(100, 'Taxable Amount'),
                  setGstHeader(40, 'CGST'),
                  setGstHeader(40, 'SGST'),
                  pw.Text('Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                ]),
                pw.Row(children: [
                  pw.SizedBox(
                      width: 70,
                      child: pw.Text(gst.gstIndex,
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 100,
                      child: pw.Text(gst.taxableAmount,
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 40,
                      child: pw.Text(gst.cgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.sgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.total, textAlign: pw.TextAlign.center))
                ]),
                pw.Divider(),
                pw.Row(children: [
                  pw.SizedBox(
                      width: 70,
                      child: pw.Text('Total', textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 100,
                      child: pw.Text(gst.taxableAmount,
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 40,
                      child: pw.Text(gst.cgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.sgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.total, textAlign: pw.TextAlign.center))
                ]),
              ]),*/
                pw.SizedBox(height: 25),
                pw.Text(
                    'Thank you for ordering with ${IConstants.APP_NAME.toUpperCase()}')
              ],
            )
          ];
        },
      ),
      /*pw.Page(
        */ /*theme: pw.ThemeData.withFont(fontFallback: [
          Font.ttf(await rootBundle.load("assets/fonts/Lato-Regular.ttf")),
          Font.ttf(await rootBundle.load("assets/fonts/Lato-Bold.ttf"))
        ]),*/ /*

        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Column(
                children: [
                  pw.Text(IConstants.APP_NAME.toUpperCase()),
                  pw.Text(orderId!),
                  pw.Text(orderItemData.vieworder[0].orderType == 'Delivery'
                      ? 'HOME Delivery'
                      : 'SELF PICKUP'),
                  pw.Text(restaurantLocation[restaurantLocation.length - 2]),
                  pw.Text(restaurantLocation.last),
                  //pw.Text("Gst No: "), //Yet to fix GST Number
                  pw.Text("Mobile : ${IConstants.primaryMobile}"),
                  pw.Text("Email : ${IConstants.primaryEmail}")
                ],
              ),
              pw.Divider(),
              pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Bill to/Ship to:"),
                    pw.Text(
                        "Invoice Id: ${orderItemData.vieworder[0].invoice}"),
                    pw.Text(customerName),
                    pw.Text(customerAddress),
                    pw.SizedBox(height: 10),
                    pw.Text("Mobile : ${deliveryDetails.mobile}"),
                    pw.Text("Email : ${deliveryDetails.email}"),
                    //pw.Text("Gst No: ${deliveryDetails.gstNo}"),
                    pw.Text("Delivery Date : ${deliveryDetails.deliveryDate}"),
                    pw.Text("Delivery Time : ${deliveryDetails.deliveryTime}"),
                    pw.Text("Note : ${deliveryDetails.note}"),
                    pw.Text("Order Date : ${deliveryDetails.orderDate}"),
                    pw.Text("Payment Type : ${deliveryDetails.paymentType}")
                  ]),
              pw.Divider(),
              itemColumn(elements),
              itemColumn(totalElements),
              // if (totalSaving != "00")
              pw.Text(
                  "You Saved ₹ \u{20B9} ${IConstants.currencyFormat}$totalSaving",
                  // "You Saved  Rs$totalSaving",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontBold: pw.Font.ttf(font),
                      color: PdfColor.fromRYB(1, 0.2, 0.5))
                  */ /* style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 24)*/ /*
                  ),
              pw.Text(
                  'Wallet Payment : $walletPayment | Cash/Online Payment : ${double.parse(cashOnlinePayment) - walletPayment}'),
              */ /*
          pw.Divider(),
              pw.Divider(),
               pw.Column(children: [
                pw.Row(children: [
                  setGstHeader(70, 'GST Index'),
                  setGstHeader(100, 'Taxable Amount'),
                  setGstHeader(40, 'CGST'),
                  setGstHeader(40, 'SGST'),
                  pw.Text('Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                ]),
                pw.Row(children: [
                  pw.SizedBox(
                      width: 70,
                      child: pw.Text(gst.gstIndex,
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 100,
                      child: pw.Text(gst.taxableAmount,
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 40,
                      child: pw.Text(gst.cgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.sgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.total, textAlign: pw.TextAlign.center))
                ]),
                pw.Divider(),
                pw.Row(children: [
                  pw.SizedBox(
                      width: 70,
                      child: pw.Text('Total', textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 100,
                      child: pw.Text(gst.taxableAmount,
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 40,
                      child: pw.Text(gst.cgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.sgst, textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 35,
                      child: pw.Text(gst.total, textAlign: pw.TextAlign.center))
                ]),
              ]),*/ /*
              pw.SizedBox(height: 25),
              pw.Text(
                  'Thank you for ordering with ${IConstants.APP_NAME.toUpperCase()}')
            ],
          );
        },
      ),*/
    );
    return pdf.save();
  }

  // pw.Expanded itemColumn(List<Product> elements) {
  itemColumn(List<Product> elements) {
    return /*pw.Column(
      mainAxisSize: pw.MainAxisSize.max,
      children:*/
        [
      for (var element in elements)
        pw.Column(children: [
          pw.Row(
            children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Text(element.itemName,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: element.itemName == RowHeader.item
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal))),
              pw.Expanded(
                  child: pw.Text(element.netPrice,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: element.netPrice == RowHeader.netPrice
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal))),
              pw.Expanded(
                  child: pw.Text(element.qty,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: element.qty == RowHeader.qty
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal))),
              pw.Expanded(
                  child: pw.Text(element.total,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: element.total == RowHeader.total
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal)))
            ],
          ),
          pw.SizedBox(height: 10)
        ]),
      pw.Divider(),
    ]
        // ,)
        ;
  }

  /// TODO FileName Generation
  /// TODO Theme
  /// TODO Download option required?
  ///
  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    OpenFile.open(file.path);

    //await OpenDocument.openDocument(filePath: filePath);
  }

/* String getSubTotal(List<Product> products) {
    return products
        .fold(0.0, (double prev, element) => prev + (element.amount * element.price))
        .toStringAsFixed(2);
  }

  String getVatTotal(List<Product> products) {
    return products
        .fold(
      0.0,
          (double prev, next) => prev + ((next.price / 100 * next.vatInPercent) * next.amount),
    )
        .toStringAsFixed(2);
  }*/
}
