import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:sutlej_club/dashboard/product_page.dart';


class ProductList extends StatefulWidget {
  final DocumentSnapshot? productData;
  final String? categoryId;
  final String? productId;
  const ProductList({Key? key, this.productData, this.categoryId, this.productId}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool isLoading = false; // Declare isLoading as a member variable
  List<String> categories = [];
  ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  List<Map<String, dynamic>> totalproducts = [];
  List<Map<String, dynamic>> products = [];
  bool isScrollDone = false;
  int start = 0,
      end = 7;

  @override
  void initState() {
    fetchData();
    fetchCategory();
    fetchProducts();
    super.initState();
  }

  void fetchProducts() async {
    var querySnapshots = await FirebaseFirestore.instance.collectionGroup(
        'products').get();

    List<Map<String, dynamic>> fetchedProducts = [];

    querySnapshots.docs.forEach((doc) {
      fetchedProducts.add(doc.data());
    });

    print('Fetched Products: $fetchedProducts');

    setState(() {
      totalproducts = fetchedProducts;
      if (end < fetchedProducts.length) {
        products = fetchedProducts.sublist(start, end);
      } else {
        products = fetchedProducts;
      }
    });
  }

  void updateProducts() async {
    if (_selectedCategory != null) {
      var querySnapshots = await FirebaseFirestore.instance.collectionGroup(
          'products').where("CategoryId", isEqualTo: _selectedCategory).get();

      List<Map<String, dynamic>> fetchedProducts = [];

      querySnapshots.docs.forEach((doc) {
        fetchedProducts.add(doc.data());
      });

      print('Fetched Products: $fetchedProducts');

      setState(() {
        totalproducts = fetchedProducts;
        if (end < fetchedProducts.length) {
          products = fetchedProducts.sublist(start, end);
        } else {
          products = fetchedProducts;
        }
      });
    } else {
      var querySnapshots = await FirebaseFirestore.instance.collectionGroup(
          'products').get();

      List<Map<String, dynamic>> fetchedProducts = [];

      querySnapshots.docs.forEach((doc) {
        fetchedProducts.add(doc.data());
      });

      print('Fetched Products: $fetchedProducts');

      setState(() {
        totalproducts = fetchedProducts;
        if (end < fetchedProducts.length) {
          products = fetchedProducts.sublist(start, end);
        } else {
          products = fetchedProducts;
        }
      });
    }
  }

  void fetchData() async {
    // Simulating some asynchronous data fetching process
    await Future.delayed(Duration(seconds: 2)); // Simulate 2 seconds delay
    setState(() {
      isLoading =
      false; // Set isLoading to false when data fetching is completed
    });
  }

  void fetchCategory() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
        'categories').get();
    List<String> fetchedCategory = [];

    querySnapshot.docs.forEach((doc) {
      String categoryName = doc['categoryName'] ?? '';
      String categoryID = doc.id;
      fetchedCategory.add('$categoryID:$categoryName');
    });

    setState(() {
      categories = fetchedCategory;
      isLoading = false;
    });
  }

  Widget buildCategorySlider() {

    return categories.length == 0
        ? Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Select Category:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _selectedCategory ==
                        categories[index].split(':')[0]
                        ? Colors.white
                        : Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                            color: Colors.grey.shade300
                        )
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_selectedCategory == categories[index].split(
                          ':')[0]) {
                        _selectedCategory = null;

                        updateProducts();
                        print(_selectedCategory);
                      } else {
                        _selectedCategory = categories[index].split(':')[0];

                        updateProducts();
                        print(_selectedCategory);
                      }
                    });
                  },
                  child: Text(
                    categories[index].split(':')[1],
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff124076)
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Color(0xff124076),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xff124076)), // Change color here
        ),
      )
          : totalproducts.length == 0 ? Center(child: Text('You have no records.',
          style: TextStyle(color: Color(0xff124076))),) :
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 650) {
            return Center(
              // Your tablet/desktop layout
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  buildCategorySlider(),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, productIndex) {
                        final product = products[productIndex];
                        return Card(
                          elevation: 2,
                          color: Colors.grey.shade100,
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            contentPadding:
                            EdgeInsets.only(left: 0.0, right: 0.0),
                            leading: CircleAvatar(
                              radius: 48, // Image radius
                              backgroundImage:
                              NetworkImage(product['imageUrl']),
                            ),
                            title: Text(
                              product['productCode'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              product['productName'],
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.qr_code,
                                    color: Color(0xff124076),
                                  ),
                                  onPressed: () {
                                    _showQRPopup(
                                        context,
                                        product['productName'],
                                        product['id'],
                                        product['BrandId'],
                                        product['CategoryId']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: Color(0xff124076),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductPage(
                                              productData: product,
                                              categoryId:
                                              product['CategoryId'],
                                              productId: product['id'],
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.grey.shade800,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          backgroundColor: Colors.white,
                                          title: Text(
                                            "Confirm Delete",
                                            style: TextStyle(
                                                color:Colors.black),
                                          ),
                                          content: Text(
                                            "Are you sure you want to delete this product?",
                                            style: TextStyle(
                                                color:  Colors.black),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      color: Colors.grey.shade700)),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Delete",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () async {
                                                Reference storageRef =
                                                FirebaseStorage
                                                    .instance
                                                    .ref();
                                                final desertRef =
                                                storageRef.child(
                                                    "product/${product['filename']}");
                                                await desertRef
                                                    .delete();

                                                FirebaseFirestore.instance
                                                    .collection('categories')
                                                    .doc(product[
                                                'CategoryId'])
                                                    .collection(
                                                    'products')
                                                    .doc(product['id'])
                                                    .delete()
                                                    .then((_) {
                                                  print(
                                                      "Product deleted successfully");
                                                }).catchError((error) {
                                                  print(
                                                      "Failed to delete product: $error");
                                                });

                                                Navigator.of(context)
                                                    .pushReplacementNamed(
                                                    '/productList');

                                                // Close the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff124076),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }


  void _showQRPopup(BuildContext context, String name, String id, String Bid,
      String Cid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16.0),
              // border: Border.all(color: Colors.white)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Generated QR Code',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildQrWithLogo(id, name, Bid, Cid),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _downloadQR(context, id, name),
                      child:
                      Text('Download', style: TextStyle(color: Colors.amber)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadQR(BuildContext context, String id, String name) async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final tempPath = directory.path;
      final tempFile = await File('$tempPath/temp_image.png').create();
      await tempFile.writeAsBytes(pngBytes);
      await ImageGallerySaver.saveImage(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'QR code saved to gallery',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  GlobalKey _globalKey = GlobalKey();

  Widget _buildQrWithLogo(String id, String name, String Bid, String Cid) {
    String collectiveId = Cid + ',' + Bid + "," + id;
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: 220,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Minimize vertical size
          children: [
            Image.asset(
              'assets/unnamed.png',
              width: 60,
              height: 13,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 15), // Add spacing between name and QR code
            Container(
              width: 150, // Reduce QR code width for better proportion
              height: 150, // Reduce QR code height for better proportion
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white
                        .withOpacity(0.25), // Add shadow for depth effect
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Transform.scale(
                scale: 0.97,
                child: QrImageView(
                  data: collectiveId,
                  version: QrVersions.auto,
                  size: 200, // This is the base size of the QR code
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Product : $name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}