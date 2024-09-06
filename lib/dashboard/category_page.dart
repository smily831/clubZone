import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../global/common/toast.dart';



class CategoryPage extends StatefulWidget {
  final DocumentSnapshot? categoryData;
  final String? categoryId; // Make categoryData nullable

  const CategoryPage({Key? key, this.categoryData, this.categoryId})
      : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String filename;
  String? imagePath;
  bool showLoader = false;
  String? imageUrl;
  bool clicked = false;
  XFile? pickedImage;

  late TextEditingController categoryController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(
        text: widget.categoryData != null
            ? widget.categoryData!['categoryName']
            : '');
    descriptionController = TextEditingController(
        text: widget.categoryData != null
            ? widget.categoryData!['categoryDescription']
            : '');
    setState(() {
      imageUrl = widget.categoryData?['imageUrl'] ?? null;
      filename =
      widget.categoryData != null ? widget.categoryData!['filename'] : '';
    });
  }

  @override
  void dispose() {
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Modify this function to update an existing category
  void updateCategory() async {
    try {
      setState(() {
        showLoader = true;
      });

      Reference storageRef = FirebaseStorage.instance.ref();
      if (filename != widget.categoryData?['filename']) {
        final desertRef =
        storageRef.child('category/${widget.categoryData?['filename']}');
        await desertRef.delete();
        Reference brandDirRef = storageRef.child('category');
        Reference uploadRef = brandDirRef.child(filename);
        await uploadRef.putData(
          await pickedImage!.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await uploadRef.getDownloadURL();
      }

      setState(() {
        clicked = false;
      });

      final categoryRef = FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryData!.id);

      await categoryRef.update({
        "categoryName": categoryController.text.trim(),
        "categoryDescription": descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'filename': filename,
      });

      setState(() {
        showLoader = false;
      });

      Navigator.of(context).pop();
    } catch (e) {
      print("Error updating category: $e");
      setState(() {
        showLoader = false;
      });
    }
  }

  // Modify this function to add a new category
  void addCategory() async {
    if (categoryController.text.isEmpty) {
      showToast(message: "Enter Category Name");
    } else if (descriptionController.text.isEmpty) {
      showToast(message: "Enter Category Description");
    } else if (imageUrl == null) {
      showToast(message: "Enter Image");
    } else {
      try {
        setState(() {
          showLoader = true; // Show loader when adding category
        });
        Reference storageRef = FirebaseStorage.instance.ref();
        Reference brandDirRef = storageRef.child('category');
        Reference uploadRef = brandDirRef.child(filename);
        await uploadRef.putData(
          await pickedImage!.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await uploadRef.getDownloadURL();
        setState(() {
          clicked = false;
        });
        var docRef =
        await FirebaseFirestore.instance.collection("categories").add(
          {
            "categoryName": categoryController.text.trim(),
            "categoryDescription": descriptionController.text.trim(),
            'imageUrl': imageUrl,
            'filename': filename,
          },
        );

        String categoryId = docRef.id;
        await docRef.update({"id": categoryId});

        setState(() {
          showLoader = false;
        });

        Navigator.of(context).pop();
        setState(() {
          showLoader = false; // Hide loader after category is added
        });
      } catch (e) {
        print("Error adding category: $e");
        setState(() {
          showLoader = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    pickedImage = await ImagePicker().pickImage(source: ImageSource.camera
    );

    if (pickedImage == null) return;

    setState(() {
      filename = pickedImage!.name + DateTime.now().toString();
    });
    imagePath = pickedImage!.path;
    imageUrl = imageUrl != null ? imageUrl : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Enter Categories"),
        backgroundColor: Colors.blue,
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
      body: showLoader
          ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ))
          : SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 650) {
              return Center(
                child: Container(
                  width: 950,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Category Nmae',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500),
                        controller: categoryController,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Category Name",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 193, 189, 189),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Enter Category Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 20, 171, 45),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Category Description',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 193, 189, 189),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            "Please select an image",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 18,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Color.fromARGB(255, 20, 171, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              "Pick Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                clicked = true;
                              });
                              _pickImageFromGallery();
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      imageUrl == null
                          ? clicked
                          ? Text("Image is Uploading",
                          style: TextStyle(color: Colors.white))
                          : Text("")
                          : Text(
                        filename.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        height: 10,
                      ),

                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Color.fromARGB(255, 20, 171, 45),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 18),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () {
                            widget.categoryData != null
                                ? updateCategory()
                                : addCategory();
                          },
                          child: widget.categoryData != null
                              ? const Text("Update Category")
                              : const Text("Add Category"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Category Name',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      style: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500),
                      controller: categoryController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Category Name",
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 193, 189, 189),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Enter Category Description',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      style: TextStyle(
                        color: Color.fromARGB(255, 193, 189, 189),
                        fontWeight: FontWeight.w500,
                      ),
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: 'Category Description',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 193, 189, 189),
                            fontWeight: FontWeight.w500,
                          )),
                    ),

                    SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Please select an image",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Color.fromARGB(255, 20, 171, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            "Pick Image",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              clicked = true;
                            });
                            _pickImageFromGallery();
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    imageUrl == null
                        ? clicked
                        ? Text("Image is Uploading",
                        style: TextStyle(color: Colors.blue))
                        : Text("")
                        : Text(
                      filename.toString(),
                      style: TextStyle(color: Colors.blue),
                    ),
                    SizedBox(height: 25),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          widget.categoryData != null
                              ? updateCategory()
                              : addCategory();
                        },
                        child: widget.categoryData != null
                            ? const Text("Update Category")
                            : const Text("Add Category"),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}