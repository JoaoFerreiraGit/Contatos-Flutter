import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

import 'contact_page.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();


  @override
  void initState() {
    super.initState();
    setState(() {
      _getAllContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
          itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de A-Z"),
              value: OrderOptions.orderaz,
            ),
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordenar de Z-A"),
              value: OrderOptions.orderza,
            )
          ],
          onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null ?
                          FileImage(File(contacts[index].img)) :
                          AssetImage("assets/images/person.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacts[index].name ?? "",
                      style: TextStyle(fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              )
            ])),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){},
              builder: (context){
                return Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          child: Text("Ligar",
                              style: TextStyle(color: Colors.indigo, fontSize: 20, )
                          ),
                          onPressed: () async{
                            launch("tel:${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                        )
                      ),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: TextButton(
                            child: Text("Editar",
                                style: TextStyle(color: Colors.indigo, fontSize: 20, )
                            ),
                            onPressed: (){
                              Navigator.pop(context);
                              _showContactPage(contact: contacts[index]);
                            },
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: TextButton(
                            child: Text("Deletar",
                                style: TextStyle(color: Colors.indigo, fontSize: 20, )
                            ),
                            onPressed: (){
                              helper.deleteContact(contacts[index].id);
                              setState(() {
                                contacts.removeAt(index);
                                Navigator.pop(context);
                              });
                            },
                          )
                      )
                    ],
                  )
                );
              }
          );
        }
    );
  }

  void _showContactPage({Contact contact }) async {
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context)=> ContactPage(contact: contact,))
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
      } else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch (result){
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
