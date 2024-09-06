import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:sutlej_club/dashboard/category_page.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Set isLoading to true when starting to load data
    fetchData();
  }

  void fetchData() async {
    // Simulating some asynchronous data fetching process
    await Future.delayed(Duration(seconds: 1)); // Simulate 2 seconds delay
    setState(() {
      isLoading =
      false; // Set isLoading to false when data fetching is completed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor:  Color(0xff124076),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
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
          : CategoryListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Color(0xff124076),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CategoryListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>( Color(0xff124076)),
              ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return Center(
              child: Text('You have no records.',
                  style: TextStyle(color:  Color(0xff124076))));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Center(
                child: Container(
                  width: 950,
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final category = documents[index];
                        return Card(
                          elevation: 3,
                          color:  Color(0xff124076),
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            contentPadding:
                            EdgeInsets.only(left: 0.0, right: 0.0),
                            leading: CircleAvatar(
                              radius: 48, // Image radius
                              backgroundImage:
                              NetworkImage(category['imageUrl']),
                            ),

                            title: Text(
                              category['categoryName'],
                              style: TextStyle(
                                  color: Color(0xff124076)),
                            ),
                            subtitle: Text(
                              category['categoryDescription'],
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.qr_code,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _showQRPopup(
                                        context,
                                        category['categoryName'],
                                        category['id']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoryPage(
                                          categoryData: category,
                                          categoryId: category.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor:  Color(0xff124076),
                                          surfaceTintColor: Color(0xff124076),
                                          title: Text("Confirm Delete",
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                          content: Text(
                                              "Are you sure you want to delete this category?",
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      color: const Color
                                                          .fromARGB(255, 103, 103, 103))),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () async {
                                                Reference storageRef =
                                                FirebaseStorage.instance
                                                    .ref();
                                                final desertRef =
                                                storageRef.child(
                                                    "category/${category['filename']}");
                                                await desertRef.delete();
                                                FirebaseFirestore.instance
                                                    .collection('categories')
                                                    .doc(category['id']) // Assuming category.id is the document ID
                                                    .delete()
                                                    .then((_) {
                                                  print(
                                                      "Category deleted successfully");
                                                }).catchError((error) {
                                                  print(
                                                      "Failed to delete category: $error");
                                                });

                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
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
                ),
              );
            } else {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final category = documents[index];
                    return Card(
                      elevation: 2,
                      color:  Colors.grey.shade100,
                      surfaceTintColor: Colors.grey.shade50,
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                        leading: CircleAvatar(
                          radius: 48, // Image radius
                          backgroundImage: NetworkImage(category['imageUrl']),
                        ),
                        title: Text(
                          category['categoryName'],
                          style: TextStyle(
                              color: Colors.black),
                        ),
                        subtitle: Text(
                          category['categoryDescription'],
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
                                _showQRPopup(context, category['categoryName'],
                                    category['id']);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Color(0xff124076),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryPage(
                                      categoryData: category,
                                      categoryId: category.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      alignment: Alignment.center,
                                      title: Text("Confirm Delete",
                                          style: TextStyle(
                                            color: Colors.black,
                                          )),
                                      content: Text(
                                          "Are you sure you want to delete this category?",
                                          style: TextStyle(
                                            color: Colors.black,
                                          )),
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
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onPressed: () async {
                                            Reference storageRef =
                                            FirebaseStorage.instance.ref();
                                            final desertRef = storageRef.child(
                                                "category/${category['filename']}");
                                            await desertRef.delete();
                                            FirebaseFirestore.instance
                                                .collection('categories')
                                                .doc(category
                                                .id) // Assuming category.id is the document ID
                                                .delete()
                                                .then((_) {
                                              print(
                                                  "Category deleted successfully");
                                            }).catchError((error) {
                                              print(
                                                  "Failed to delete category: $error");
                                            });

                                            Navigator.of(context)
                                                .pop(); // Close the dialog
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
              );
            }
          },
        );
      },
    );
  }
}

void _showQRPopup(BuildContext context, String name, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Color(0xff124076))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Generated QR Code',
                  style: TextStyle(
                    color: Color(0xff124076),
                    fontSize: 18.0,
                  ),
                ),
              ),

              _buildQrWithLogo(id, name),

              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () => _downloadQR(context, id, name),
                    child:
                    Text('Download', style: TextStyle(color: Color(0xff124076))),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: Color(0xff124076)),
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
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
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

Widget _buildQrWithLogo(String id, String name) {
  return RepaintBoundary(
    key: _globalKey,
    child: Container(
      width: 220,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Minimize vertical size
        children: [
          Image.asset(
            'assets/unnamed.png',
            width: 60,
            height: 50,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 15), // Add spacing between name and QR code
          Container(
            width: 150, // Reduce QR code width for better proportion
            height: 150, // Reduce QR code height for better proportion
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  10.0), // Add border radius for rounded corners
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25), // Add shadow for depth effect
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Transform.scale(
              scale: 0.97,
              child: QrImageView(
                data: id,
                version: QrVersions.auto,
                size: 200, // This is the base size of the QR code
                backgroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Category : $name',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}