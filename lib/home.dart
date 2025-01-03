import 'package:flutter/material.dart';
import 'addFood.dart';
import 'editFood.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> obatList = [];
  List<Map<String, dynamic>> filteredList = [];
  String keywordCari = '';

  User? currentUser;
  String userName = 'Nama tidak tersedia';
  String userEmail = 'Email tidak tersedia';

  @override
  void initState() {
    super.initState();
    fetchObat();
  }

  void fetchObat() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference obat = firestore.collection('obat');

    obat.snapshots().listen((snapshot) {
      List<Map<String, dynamic>> tempList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      setState(() {
        obatList = tempList;
        filteredList = tempList;
      });
    });
  }

  void searchobat(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = obatList;
      } else {
        filteredList = obatList.where((obat) {
          final descMatch =
              obat['desc_task']?.toLowerCase()?.contains(query.toLowerCase()) ??
                  false;
          final dateMatch = obat['due_date']?.contains(query) ?? false;
          return descMatch || dateMatch;
        }).toList();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _getUserData(currentUser!.uid);
    }
  }

  void _getUserData(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['username'] ?? 'Nama tidak tersedia';
          userEmail = userDoc.data()?['email'] ?? 'Email tidak tersedia';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void searchFood(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = obatList;
      } else {
        filteredList = obatList.where((obat) {
          final nameMatch =
              obat['name']!.toLowerCase().contains(query.toLowerCase());
          final priceMatch = obat['price']!.contains(query);
          return nameMatch || priceMatch;
        }).toList();
      }
    });
  }

  void AddObat(String name, String price, String description) {
    setState(() {
      obatList.add({
        'name': name,
        'price': price,
        'Pict': 'assets/default_food.png',
        'Desc': description,
      });
      searchFood(keywordCari);
    });
  }

  void editObat(int index, String name, String price, String description) {
    setState(() {
      obatList[index] = {
        'name': name,
        'price': price,
        'Pict': obatList[index]['Pict'] ?? 'assets/default_food.png',
        'Desc': description,
      };
      filteredList = obatList;
    });
  }

  void deleteFood(Map<String, String> foodToDelete) {
    setState(() {
      obatList.removeWhere((obat) {
        return obat['id'] != null && obat['id'] == foodToDelete['id'];
      });
      filteredList = obatList;
    });
  }

  void _showDeleteDialog(Map<String, String> obat) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text('Apakah Anda yakin ingin menghapus ${obat['name']}?'),
            actions: [
              //Tombol Batal
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //nutup dialog
                },
                child: const Text('Batal'),
              ),
              //Tombol Hapus
              TextButton(
                onPressed: () {
                  deleteFood(obat); // panggil fungsi delete
                  Navigator.of(context).pop();
                  _showAfterDelete(obat);
                },
                child: const Text('Hapus'),
              ),
            ],
          );
        });
  }

  void _showAfterDelete(Map<String, String> obat) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Informasi'),
            content: Text('${obat['name']} berhasil dihapus'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //nutup dialog
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(userName, style: TextStyle(color: Colors.black)),
              accountEmail:
                  Text(userEmail, style: TextStyle(color: Colors.black)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 138, 202, 255),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pushNamed(context, 'home');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text("About"),
              onTap: () {
                Navigator.pushNamed(context, 'profile_page');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Manage Data'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddObatPage(onAddObat: AddObat),
                ),
              );
            },
            icon: Icon(Icons.add),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              onChanged: (value) {
                keywordCari = value;
                searchFood(keywordCari);
              },
              decoration: InputDecoration(
                hintText: 'Cari Makanan/Harga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchFood(keywordCari);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredList.isEmpty
          ? Center(child: Text('Tidak ada keyword yang cocok'))
          : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final obat = filteredList[index];
                return Container(
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        obat['Pict']!,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.medication,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(obat['name']!, style: TextStyle(fontSize: 20)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //rata kiri
                      children: [
                        Text('Harga: Rp ${obat['price']}',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Detail Obat'),
                            content: Text(
                                'Apakah Anda ingin melihat detail obat ${obat['name']}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    // MaterialPageRoute(
                                    // builder: (context) => ObatDetailPage(
                                    //       name: obat['name']!,
                                    //       price: obat['price']!,
                                    //       Desc: obat['Desc']!,
                                    //       Pict: obat['Pict'],

                                    //     )),
                                    MaterialPageRoute(
                                      builder: (context) => ObatPage(
                                        obatName: obat['name'] ?? 'Nama Obat',
                                        obatPrice:
                                            obat['price'] ?? 'Harga Obat',
                                        obatPict: obat['Pict'] ??
                                            'assets/default_food.png',
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Lanjut'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Batal'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditFoodPage(
                                          name: obat['name']!,
                                          price: obat['price']!,
                                          description: obat['Desc']!,
                                          onEditFood: (newName, newPrice,
                                              newDescription) {
                                            editObat(index, newName, newPrice,
                                                newDescription);
                                          },
                                        )));
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _showDeleteDialog(obat);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ObatPage extends StatelessWidget {
  final String? obatName;
  final String? obatPrice;
  final String? obatPict;
  final String? obatDesc;

  ObatPage({this.obatName, this.obatPrice, this.obatPict, this.obatDesc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => EditFoodPage(
              //               name: this.obatName!,
              //               price: this.obatName!,
              //               description: this.obatName!,
              //               onEditFood: (newName, newPrice, newDescription) {
              //                 editObat(
              //                     index, newName, newPrice, newDescription);
              //               },
              //             )));
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              //_showDeleteDialog(obat);
            },
            icon: Icon(Icons.delete),
          ),
        ],
        centerTitle: true,
        title: Text('Detail Obat'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            // Profile Photo
            Container(
              width: 400,
              height: 400,
              child: Image.asset(
                obatPict ?? 'assets/default_food.png',
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.medication_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            // Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_outlined),
                SizedBox(width: 8),
                Text(
                  obatName ?? 'Nama Obat',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_outlined),
                SizedBox(width: 8),
                Text(
                  obatPrice ?? 'Harga Obat',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Phone
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 8),
                Text(
                  obatDesc ?? 'Deskripsi Obat tidak tersedia',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
