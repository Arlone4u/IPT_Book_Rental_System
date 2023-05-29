import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'auth_provider.dart';
import 'dart:async';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _books = [];

  @override
  void initState() {
    super.initState();
    _getBooks();
  }

  Future<void> _getBooks() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/books/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _books = json.decode(response.body);
        _books.forEach((book) {
          book['daysRented'] = 0; // Initialize with 0 days rented
        });
      });
    } else {
      throw Exception('Failed to retrieve books');
    }
  }

  Future<void> _rentBook(BuildContext context, dynamic book) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rentedBooksCount = authProvider.rentedBooksCount;

    if (rentedBooksCount >= 3) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Maximum Limit Reached'),
            content: Text('You have already rented 3 books. Cannot rent more.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    int daysRented = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rent Book'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              daysRented = int.tryParse(value) ?? 0;
            },
            decoration: InputDecoration(
              labelText: 'Number of Days',
              hintText: 'Enter the number of days to rent the book',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processRental(context, book, daysRented);
              },
              child: Text('Rent'),
            ),
          ],
        );
      },
    );
  }

  void _processRental(
      BuildContext context, dynamic book, int daysRented) async {
    if (daysRented <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid number of days'),
        ),
      );
      return;
    }

    // Perform the rental logic here
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final url =
        Uri.parse('http://127.0.0.1:8000/api/books/${book['id']}/rent/');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
      body: json.encode({
        'rental_days': daysRented,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book rented successfully'),
        ),
      );
      _getBooks();
      authProvider.incrementRentedBooksCount();
      // Show dialog after successful rental
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Book Rented'),
            content: Text('You have successfully rented the book.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to rent book. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.username;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Hello $username!'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
        backgroundColor: Color(0xff192028),
      ),
      body: Container(
        color: Color(0xff192028),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  final isAvailable = book['available'];

                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        book['image'],
                        width: 48.0,
                        height: 48.0,
                      ),
                      title: Text(
                        book['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price: ₱${book['price']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                          Text(
                            book['author'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Description: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(239, 0, 0, 0),
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: '${book['description']}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 87, 77, 77),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      trailing: isAvailable
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Days Rented: ${book['daysRented']}',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                    Text(
                                      'Price: ₱${book['price'] * book['daysRented']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaY: 15, sigmaX: 15),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        // Add your onTap logic here
                                      },
                                      child: ElevatedButton(
                                        onPressed: isAvailable
                                            ? () async {
                                                await _rentBook(context, book);
                                              }
                                            : null,
                                        child: Text('Rent'),
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Colors.white.withOpacity(.05),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0,
                                              horizontal:
                                                  16.0), // Adjusted padding
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Rented',
                              style: TextStyle(
                                color: Color.fromARGB(255, 180, 23, 23),
                                fontSize: 14,
                              ),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(
                  height: 80), // Add SizedBox for extra space at the bottom
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/Rents'),
          child: Icon(Icons.local_library_outlined),
          backgroundColor: Color(0xff192028),
          shape: CircleBorder(),
        ),
      ),
    );
  }
}
