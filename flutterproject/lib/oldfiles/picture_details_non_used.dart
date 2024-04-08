import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Não usado

class ItemDetails extends StatelessWidget {
  ItemDetails(this.itemId, this.itemName, {Key? key}) : super(key: key) {
    _reference = FirebaseFirestore.instance.collection('images').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  String itemName;
  late DocumentReference _reference;

  //_reference.get()  --> returns Future<DocumentSnapshot>
  //_reference.snapshots() --> Stream<DocumentSnapshot>
  late Future<DocumentSnapshot> _futureData;
  late Map data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName),
        actions: [
          
          IconButton(onPressed: (){
            //Delete the item
            _reference.delete();
          }, icon: Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            //Get the data
            DocumentSnapshot documentSnapshot = snapshot.data;
            data = documentSnapshot.data() as Map;

            //display the data
            return Column(
              children: [
                Text('${data['name']}'),
                Text('${data['quantity']}'),
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}