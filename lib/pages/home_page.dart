import 'package:obat/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:obat/pages/obatDetail_page.dart';
import 'package:obat/pages/manage_obat.dart';
import 'package:obat/pages/cart_page.dart';
import 'package:obat/pages/cart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;

  List<Map<String, dynamic>> obatList = [];
  List<Map<String, dynamic>> filteredList = [];
  String keywordCari = '';
  User? currentUser;
  String userName = 'Nama tidak tersedia';
  String userEmail = 'Email tidak tersedia';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset(0.0, 0.0))
            .animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOut,
    ));
    _controller!.forward();
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
        isLoading = false;
      });
    });
  }

  void searchobat(String query) {
    setState(() {
      keywordCari = query;
      if (query.isEmpty) {
        filteredList = obatList;
      } else {
        filteredList = obatList.where((obat) {
          final namaMatch = (obat['nama'] ?? ' ')
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
          final hargaMatch = (obat['harga'] ?? '').toString().contains(query);
          return namaMatch || hargaMatch;
        }).toList();
      }
    });
  }

  Widget _buildSkeletonLoading(int count) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void addToCart(Map<String, dynamic> obat) {
    Provider.of<CartProvider>(context, listen: false).addToCart(obat);
  }

  String formatHarga(String harga) {
    try {
      final parsedHarga = double.parse(harga.replaceAll(RegExp('[^0-9]'), ''));
      final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
      return format.format(parsedHarga);
    } catch (e) {
      return 'Rp 0';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(userName, style: TextStyle(color: Colors.black)),
              accountEmail:
                  Text(userEmail, style: TextStyle(color: Colors.black)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.purple[50],
                child: Icon(Icons.person, size: 40.0, color: Colors.white),
              ),
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 222, 216, 254)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text("About"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.medication_outlined),
              title: Text("Manage Obat"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageObat()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Cashier', style: TextStyle(color: Colors.white)),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingCartPage(),
                        ),
                      );
                    },
                  ),
                  if (cartProvider.cartItemCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.cartItemCount}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              onChanged: (value) {
                searchobat(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari Obat/Harga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('obat').snapshots(),
        builder: (context, snapshot) {
          if (isLoading && filteredList.isEmpty) {
            return _buildSkeletonLoading(20);
          }

          if (snapshot.hasData) {
            obatList = snapshot.data!.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              };
            }).toList();

            filteredList = keywordCari.isEmpty
                ? obatList
                : obatList.where((obat) {
                    final namaMatch = (obat['nama'] ?? ' ')
                        .toString()
                        .toLowerCase()
                        .contains(keywordCari.toLowerCase());
                    final hargaMatch =
                        (obat['harga'] ?? '').toString().contains(keywordCari);
                    return namaMatch || hargaMatch;
                  }).toList();

            if (filteredList.isEmpty) {
              return Center(child: Text('Tidak ada hasil pencarian.'));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final obat = filteredList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ObatDetailPage(
                            obatId: obat['id'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: obat['pict'] != null &&
                                      obat['pict'].isNotEmpty
                                  ? Image.asset(
                                      obat['pict'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.medication,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.medication,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  obat['nama'] != null
                                      ? (obat['nama'].length > 15
                                          ? '${obat['nama'].substring(0, 15)}...'
                                          : obat['nama'])
                                      : 'Nama tidak tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Harga: ${formatHarga(obat['harga'].toString())}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Stok: ${obat['stok']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    addToCart(obat);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFC8ACD6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Add to Cart',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Center(child: Text('Data tidak tersedia.'));
        },
      ),
    );
  }
}
