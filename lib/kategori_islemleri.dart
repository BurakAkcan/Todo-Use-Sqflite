import 'package:flutter/material.dart';
import 'package:notlarim/utils/database_helper.dart';

import 'models/kategori.dart';

class Kategoriler extends StatefulWidget {
  const Kategoriler({Key? key}) : super(key: key);

  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori>? tumKategoriler;
  DatabaseHelper? databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper = DatabaseHelper();
    setState(() {
      tumKategoriler;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      kategoriListesiniGuncelle();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kategoriler"),
      ),
      body: ListView.builder(
        itemCount: tumKategoriler?.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              onTap: () => _kategoriGuncelle(tumKategoriler![index]),
              leading: const Icon(Icons.category_outlined),
              trailing: InkWell(
                child: const Icon(Icons.delete),
                onTap: () => (_kategoriSil(tumKategoriler![index].kategoriId!)),
              ),
              title: Text(tumKategoriler?[index].kategoriBaslik == null
                  ? ""
                  : tumKategoriler![index].kategoriBaslik!));
        },
      ),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper!.kategorListesiniGetir().then((kategoriIcerenList) {
      setState(() {
        tumKategoriler = kategoriIcerenList;
      });
    });
  }

  Future<int> _kategoriSil(int kategoriId) async {
    var sonuc = await showDialog(
        context: (context),
        builder: (context) {
          return AlertDialog(
            title: Text("Emin misiniz?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Kategoriyi sildiğinizde bununla beraber tüm notlarda silinecektir"),
                ButtonBar(
                  children: [
                    TextButton(
                      child: Text("Vazgeç"),
                      onPressed: () => (Navigator.of(context).pop()),
                    ),
                    TextButton(
                      child: const Text(
                        "Sil",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        if (kategoriId > 1) {
                          databaseHelper!.kategoriSil(kategoriId);
                          setState(() {
                            kategoriListesiniGuncelle();
                            Navigator.of(context).pop();
                          });
                        } else {
                          null;
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        });
    return sonuc ?? 1;
  }

  _kategoriGuncelle(Kategori tumKategoriler) {}
}
