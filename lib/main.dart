import 'package:flutter/material.dart';
import 'package:notlarim/kategori_islemleri.dart';
import 'package:notlarim/models/kategori.dart';
import 'package:notlarim/models/notlar.dart';
import 'package:notlarim/not_detay.dart';
import 'package:notlarim/utils/database_helper.dart';
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databasehelper = DatabaseHelper();
    databasehelper.notlariGetir();
    return MaterialApp(
      title: "Not Uygulması",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  NotListesi({Key? key}) : super(key: key);
  var formKey = GlobalKey<FormState>();
  String? yeniKategoriAdi;
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => ([
              PopupMenuItem(
                child: ListTile(
                  onTap: kategorilerSayfasinaGit(context),
                  title: Text("Kategoriler"),
                  leading: Icon(Icons.category),
                ),
              ),
            ]),
          ),
        ],
        title: const Text("Not Uygulaması"),
        centerTitle: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            tooltip: "kategori ekle",
            onPressed: () {
              kategoriEkleDialog(context);
            },
            child: const Icon(Icons.add_circle_rounded),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: null,
            tooltip: "not ekle",
            onPressed: () {
              return _detaySayfasinaGit(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (deger) {
                      yeniKategoriAdi = deger;
                    },
                    decoration: const InputDecoration(
                      labelText: "Kategori Adı",
                      border: OutlineInputBorder(),
                    ),
                    validator: (girilenKategori) {
                      if ((girilenKategori?.length ?? 0) < 3) {
                        return "En az 3 harfli bir değer giriniz";
                      }
                    },
                  ),
                ),
              ),
//birden fazla butonum varsa   buton bar eklerim
              ButtonBar(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Vazgeç")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          print(yeniKategoriAdi);
                          databaseHelper
                              .kategoriEkle(Kategori(yeniKategoriAdi))
                              .then((value) {
                            if (value > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text("kategori eklendi"),
                                ),
                              );
                              //kaydettikten sonra çıksın diye yaptık bunu
                              Navigator.of(context).pop();
                            }
                          });
                          //burada databaseHelper sınfından kategoriEkle metodunu çağırdık o da bizden Kategori türünde birşey bekliyor kendi
                          // kurucu metodunu kullanarak yazdığımız başlığı buraya yeni bir kategori nesnesi üretiyormuş gibi yazdık
                        }
                      },
                      child: const Text("Kaydet")),
                ],
              ),
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotDetay(
          baslik: "Yeni Not",
        ),
      ),
    );
  }

  kategorilerSayfasinaGit(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const Kategoriler(),
    ));
  }
}

class Notlar extends StatefulWidget {
  const Notlar({Key? key}) : super(key: key);

  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar = [];
  late DatabaseHelper databaseHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper = DatabaseHelper();

    setState(() {
      databaseHelper.notListesiniGetir();
    });
  }

  /* Future getNotlar() async {
    var not = await databaseHelper!.notlariGetir();
    for (Map okunanNot in not) {
      tumNotlar.add(Not.fromMap(okunanNot as Map<String, dynamic>));
    }
    
  }*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseHelper.notListesiniGetir(),
        builder: (context, AsyncSnapshot<List<Not>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            tumNotlar = snapshot.data!;

            return ListView.builder(
                itemCount: tumNotlar.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    leading: CircleAvatar(
                      maxRadius: 10,
                      backgroundColor: tumNotlar[index].notOncelik == 0
                          ? Colors.blue
                          : tumNotlar[index].notOncelik == 1
                              ? Colors.yellow
                              : Colors.red,
                    ),
                    title: Text(
                      tumNotlar[index].notBaslik.toString(),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Text("Kategori:"),
                                const SizedBox(width: 5),
                                Text(
                                    tumNotlar[index].kategoriBaslik.toString()),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Oluşturma Tarihi:"),
                                SizedBox(width: 5),
                                Text(databaseHelper
                                    .dateFormat(
                                      DateTime.parse(
                                          tumNotlar[index].notTarih!),
                                    )
                                    .toString()),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text(tumNotlar[index].notIcerik.toString()),
                            ),
                            ButtonBar(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MaterialButton(
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notId!, context),
                                  child: const Text(
                                    "Sil",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => NotDetay(
                                                baslik: "Notu Düzenle",
                                                duzenlenecekNot:
                                                    tumNotlar[index])));
                                  },
                                  child: const Text(
                                    "Güncelle",
                                    style: TextStyle(color: Colors.greenAccent),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  _oncelikAta(int? notOncelik) {
    switch (notOncelik) {
      case 0:
        return "Düşük";

      case 1:
        return "orta";
      case 2:
        return "yüksek";
    }
  }

  Future _notSil(int notId, BuildContext context) async {
    await databaseHelper.notSil(notId).then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Not başarıyla silindi"),
            ),
          ),
        );
    setState(() {});
  }

  _detaySayfasinaGit(BuildContext context, Not not) {}
}
