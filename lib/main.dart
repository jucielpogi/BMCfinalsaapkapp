import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FittedStoreApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class FittedStoreApp extends StatelessWidget {
  const FittedStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JYZRIZ Streetwear',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF18181B),
        primaryColor: Colors.black,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// ==========================================
// AUTH WRAPPER
// ==========================================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF18181B),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        if (snapshot.hasData) {
          return const MobileFrameWrapper();
        }
        return const LoginScreen();
      },
    );
  }
}

// ==========================================
// LOGIN & REGISTRATION SCREEN (KASAMA NA SA FRAME)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true; // PARA SA EYE ICON

  Future<void> _submit() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;
        DatabaseReference ref = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://bmcfinals-8179e-default-rtdb.asia-southeast1.firebasedatabase.app',
        ).ref("users").child(uid);

        await ref.set({
          "name": _nameController.text.trim(),
          "address": _addressController.text.trim(),
          "phone": _phoneController.text.trim(),
          "email": _emailController.text.trim(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // GINAWA NATING CELLPHONE FRAME ANG LOGIN SCREEN
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      body: Center(
        child: Container(
          width: 380,
          height: 750,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.black, width: 8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Status bar para magmukhang totoong phone
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('9:41', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 120,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.signal_cellular_alt, size: 16),
                        SizedBox(width: 4),
                        Icon(Icons.wifi, size: 16),
                        SizedBox(width: 4),
                        Icon(Icons.battery_full, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              
              // LOGIN FORM
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'JYZRIZ STREETWEAR',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin ? 'Welcome Back!' : 'Create an Account',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // KUNG REGISTER, IPAKITA ANG FULL NAME, ADDRESS, PHONE
                      if (!isLogin) ...[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Delivery Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // EMAIL
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // PASSWORD NA MAY EYE ICON
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                      const SizedBox(height: 20),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isLogin ? 'Login' : 'Register',
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PALITAN NG MODE (LOGIN/REGISTER)
                      TextButton(
                        onPressed: () => setState(() => isLogin = !isLogin),
                        child: Text(
                          isLogin
                              ? "Don't have an account? Register"
                              : "Already have an account? Login",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// FIREBASE SAVE FUNCTION (9 ITEMS)
// ==========================================
void addMultipleProductsToFirebase(BuildContext context) async {
  final List<Map<String, dynamic>> itemsList = [
    {"name": "Supreme Camo Hoodie", "price": 2800.0, "status": "Available"},
    {"name": "BAPE Ape Head Camo Tee", "price": 5899.0, "status": "Available"},
    {"name": "Supreme Hooded Sweatshirt", "price": 2250.0, "status": "Available"},
    {"name": "BAPE Pullover Hoodie", "price": 5599.0, "status": "Available"},
    {"name": "Carhartt Wip Logo", "price": 1800.0, "status": "Available"},
    {"name": "Chrome Hearts longsleeve", "price": 4500.0, "status": "Available"},
    {"name": "Supreme Box Logo Tee", "price": 6500.0, "status": "Available"},
    {"name": "BAPE Shark Zip Hoodie", "price": 2500.0, "status": "Available"},
    {"name": "Streetwear Shorts", "price": 9999.0, "status": "Available"},
  ];

  try {
    DatabaseReference ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://bmcfinals-8179e-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref("mga_produkto");

    for (var item in itemsList) {
      await ref.push().set(item);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagumpay: 9 items na-save na sa Firebase!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sa pag-save sa Firebase: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ==========================================
// MAIN UI & FRAME WRAPPER (STORE)
// ==========================================
class MobileFrameWrapper extends StatefulWidget {
  const MobileFrameWrapper({super.key});

  @override
  State<MobileFrameWrapper> createState() => _MobileFrameWrapperState();
}

class _MobileFrameWrapperState extends State<MobileFrameWrapper> {
  Map<String, String>? selectedProduct;
  String selectedSize = 'Medium';
  Map<String, dynamic>? userData;

  final List<Map<String, String>> cartItems = [];
  final List<Map<String, String>> orderHistory = [
    {
      'title': 'Supreme Box Logo Tee',
      'details': 'Delivered • Size: L • ₱6500',
      'status': 'Delivered',
    },
    {
      'title': 'BAPE Shark Zip Hoodie',
      'details': 'Shipping (3-5 days) • Size: M • ₱2500',
      'status': 'Shipping',
    },
  ];

  String currentView = 'home';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DatabaseReference ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://bmcfinals-8179e-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref("users").child(uid);

      final snapshot = await ref.get();
      if (snapshot.exists && mounted) {
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 380,
          height: 750,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.black, width: 8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ---------------- STATUS BAR (BATTERY SECRET BUTTON) ----------------
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('9:41',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 120,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_alt, size: 16),
                        const SizedBox(width: 4),
                        const Icon(Icons.wifi, size: 16),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => addMultipleProductsToFirebase(context),
                          child: const Icon(Icons.battery_full,
                              size: 18, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---------------- APP BAR / HEADER ----------------
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JYZRIZ streetwear',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData != null
                              ? 'Hi, ${userData!['name']}!'
                              : 'Streetwear Collection',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.history,
                              color: Colors.black, size: 24),
                          onPressed: () {
                            setState(() {
                              currentView = 'history';
                            });
                          },
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_bag_outlined,
                                  color: Colors.black, size: 24),
                              onPressed: () {
                                setState(() {
                                  currentView = 'cart';
                                });
                              },
                            ),
                            if (cartItems.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cartItems.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Colors.red, size: 20),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---------------- DYNAMIC VIEWS ----------------
              Expanded(
                child: _buildCurrentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (currentView == 'details' && selectedProduct != null) {
      return _buildProductDetailsView();
    } else if (currentView == 'cart') {
      return _buildCartView();
    } else if (currentView == 'history') {
      return _buildHistoryView();
    } else {
      return _buildHomeGrid();
    }
  }

  Widget _buildHomeGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      childAspectRatio: 0.62,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        ProductCard(
          brand: 'Supreme',
          title: 'Supreme Camo Hoodie',
          price: '₱2800',
          imageUrl:
              'https://www.resellzonecesena.com/cdn/shop/files/supreme-b-b-simon-zip-up-hooded-sweatshirt-camo-resellzone.jpg?v=1748279130&width=1065',
          onTap: (brand, title, price, img) {
            setState(() {
              selectedProduct = {
                'brand': brand,
                'title': title,
                'price': price,
                'imageUrl': img
              };
              currentView = 'details';
            });
          },
        ),
        ProductCard(
          brand: 'BAPE',
          title: 'BAPE Ape Head Camo Tee',
          price: '₱5899',
          imageUrl:
              'https://int.bape.com/cdn/shop/files/0ZXTEM007101RBKM-pdp-1.jpg?v=1787913204&width=800',
          onTap: (brand, title, price, img) {
            setState(() {
              selectedProduct = {
                'brand': brand,
                'title': title,
                'price': price,
                'imageUrl': img
              };
              currentView = 'details';
            });
          },
        ),
        ProductCard(
          brand: 'Supreme',
          title: 'Supreme Hooded Sweatshirt',
          price: '₱2250',
          imageUrl:
              'https://puresoles.ph/cdn/shop/files/Screenshot2026-04-28at11.30.27AM.png?v=1777906261&width=1946',
          onTap: (brand, title, price, img) {
            setState(() {
              selectedProduct = {
                'brand': brand,
                'title': title,
                'price': price,
                'imageUrl': img
              };
              currentView = 'details';
            });
          },
        ),
        ProductCard(
          brand: 'BAPE',
          title: 'BAPE Pullover Hoodie',
          price: '₱5599',
          imageUrl:
              'https://images.stockx.com/images/BAPE-Logo-Relaxed-Fit-Pullover-Hoodie-FW22-Green.jpg?fit=fill&bg=FFFFFF&w=700&h=500&fm=webp&auto=compress&q=90&dpr=2&trim=color&updated_at=1667200300',
          onTap: (brand, title, price, img) {
            setState(() {
              selectedProduct = {
                'brand': brand,
                'title': title,
                'price': price,
                'imageUrl': img
              };
              currentView = 'details';
            });
          },
        ),
        ProductCard(
          brand: 'Carhartt',
          title: 'Carhartt Wip logo',
          price: '₱1800',
          imageUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCapry-Wtl2qaLBOwCEk1PVqMJWcxisRHAqZufVtYhPF6VpwnrgGtnywrt&s=10',
          onTap: (brand, title, price, img) {
            setState(() {
              selectedProduct = {
                'brand': brand,
                'title': title,
                'price': price,
                'imageUrl': img
              };
              currentView = 'details';
            });
          },
        ),
        ProductCard(
          brand: 'Chrome Hearts',
          title: 'Chrome Hearts longsleeve',
          price: '₱4500',
          imageUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTVczePC_F2eSWYTVsNQ9jaASUkfwp59usjXg4fZhVpsQ75qyBOzQSjF8&s=10',
          onTap: (brand, title, price, img) {
            setState(() {
              selectedProduct = {
                'brand': brand,
                'title': title,
                'price': price,
                'imageUrl': img
              };
              currentView = 'details';
            });
          },
        ),
      ],
    );
  }

  Widget _buildProductDetailsView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    currentView = 'home';
                  });
                },
              ),
              const Text('Back to Collection',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                selectedProduct!['imageUrl']!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            selectedProduct!['brand']!,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold),
          ),
          Text(
            selectedProduct!['title']!,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          const SizedBox(height: 2),
          Text(
            selectedProduct!['price']!,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: 16, color: Colors.grey),
              SizedBox(width: 6),
              Text('Standard Shipping: 3 to 5 days',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Select Size (Small to XXL):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Small', 'Medium', 'Large', 'XL', 'XXL'].map((size) {
              bool isSelected = selectedSize == size;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSize = size;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                setState(() {
                  cartItems.add({
                    'title': selectedProduct!['title']!,
                    'price': selectedProduct!['price']!,
                    'size': selectedSize,
                    'imageUrl': selectedProduct!['imageUrl']!,
                  });
                  currentView = 'home';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully added to cart!')),
                );
              },
              child: const Text('Add to Cart',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    currentView = 'home';
                  });
                },
              ),
              const Text('Shopping Cart',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 40),
            ],
          ),
          const Divider(),
          if (userData != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deliver To:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${userData!['name']} | ${userData!['phone']}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(userData!['address'],
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text('Your cart is empty',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(item['imageUrl']!,
                              width: 45, height: 45, fit: BoxFit.cover),
                        ),
                        title: Text(item['title']!,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Size: ${item['size']} | ${item['price']}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              cartItems.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (cartItems.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  for (var item in cartItems) {
                    orderHistory.add({
                      'title': item['title']!,
                      'details':
                          'Shipping (3-5 days) • Size: ${item['size']} • ${item['price']}',
                      'status': 'Shipping',
                    });
                  }
                  setState(() {
                    cartItems.clear();
                    currentView = 'history';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Checkout successful! Added to Order History.')),
                  );
                },
                child: const Text('Proceed to Checkout',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    currentView = 'home';
                  });
                },
              ),
              const Text('Order History',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 40),
            ],
          ),
          const Divider(),
          Expanded(
            child: orderHistory.isEmpty
                ? const Center(
                    child: Text('No order history',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: orderHistory.length,
                    itemBuilder: (context, index) {
                      final order = orderHistory[index];
                      bool isShipping = order['status'] == 'Shipping';

                      return ListTile(
                        leading: Icon(
                          isShipping
                              ? Icons.local_shipping
                              : Icons.check_circle,
                          color: isShipping ? Colors.blue : Colors.green,
                        ),
                        title: Text(order['title']!,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(order['details']!,
                            style: const TextStyle(fontSize: 11)),
                        trailing: isShipping
                            ? TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    orderHistory[index]['status'] =
                                        'Cancelled';
                                    orderHistory[index]['details'] =
                                        'Cancelled by user';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Order successfully cancelled.')),
                                  );
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )
                            : const Text('Cancelled',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String brand;
  final String title;
  final String price;
  final String imageUrl;
  final Function(String, String, String, String) onTap;

  const ProductCard({
    super.key,
    required this.brand,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(brand, title, price, imageUrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.checkroom,
                            size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              brand,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              price,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}