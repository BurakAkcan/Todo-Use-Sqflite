import 'package:flutter/material.dart';
import 'package:notlarim/models/kategori.dart';
import 'package:notlarim/models/notlar.dart';
import 'package:notlarim/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String? baslik;
  Not? duzenlenecekNot;

  NotDetay({Key? key, required this.baslik, this.duzenlenecekNot})
      : super(key: key);

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler = [];
  DatabaseHelper? databaseHelper;

  int kategoriId = 1;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];
  int secilenOncelik = 0;
  String notBaslik = "", notIcerik = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    databaseHelper = DatabaseHelper();

    if (widget.duzenlenecekNot != null) {
      kategoriId = widget.duzenlenecekNot!.kategoriId!;
      secilenOncelik = widget.duzenlenecekNot!.notOncelik!;
    } else {
      kategoriId = 1;
      secilenOncelik = 0;
    }
    //burada notUpdate tarafından gönderilen Not nesnesi geliyor zaten sıfırdan oluşturulsaydı widget.duzenlenecekNot null gelirdi buraya uğramazdı
    setState(() {});
    getKategori();
  }

  getKategori() async {
    var kat = await databaseHelper!.kategorilerigetir();
    for (Map okunanMap in kat) {
      tumKategoriler.add(Kategori.fromMap(okunanMap as Map<String, dynamic>));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.baslik.toString()),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(children: [
            tumKategoriler.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      const Text(
                        " Kategori: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.redAccent, width: 1)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 24),
                        margin: const EdgeInsets.all(12),
                        child: DropdownButton<int>(
                          items: kategoriItems(),
                          onChanged: (secilenKategoriId) {
                            setState(() {
                              kategoriId = secilenKategoriId ?? 1;
                            });
                          },
                          value: kategoriId,
                        ),
                      ),
                    ],
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.duzenlenecekNot?.notBaslik ?? "",
                validator: (text) {
                  if ((text?.length ?? 1) < 2) {
                    return "Başlık en az 2 karakterli olmalı";
                  }
                },
                onSaved: (girilenBaslik) {
                  notBaslik = girilenBaslik ?? "";
                },
                decoration: const InputDecoration(
                  hintText: "Not Başlığını giriniz",
                  labelText: "Başlık",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.duzenlenecekNot?.notIcerik ?? "",
                onSaved: (girilenNot) {
                  notIcerik = girilenNot ?? "";
                },
                maxLength: 200,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Not içeriği giriniz",
                  labelText: "İçerik",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Row(
              children: [
                const Text(
                  " Öncelik: ",
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent, width: 1)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                  margin: const EdgeInsets.all(12),
                  child: notOncelik(),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Vazgeç"),
                  color: Colors.redAccent,
                ),
                MaterialButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      var suAn = DateTime.now();
                      print(databaseHelper!.dateFormat(suAn).toString());

                      print(suAn.toString());
                      if (widget.duzenlenecekNot == null) {
                        setState(() {
                          databaseHelper!
                              .notlariEkle(Not(kategoriId, notBaslik, notIcerik,
                                  suAn.toString(), secilenOncelik))
                              .then((value) {
                            if (value != 0) {
                              Navigator.of(context).pop();
                            }
                          });
                        });
                      } else {
                        setState(() {});
                        databaseHelper!
                            .notUpdate(Not.withId(
                                widget.duzenlenecekNot!.notId,
                                kategoriId,
                                notBaslik,
                                notIcerik,
                                suAn.toString(),
                                secilenOncelik))
                            .then((guncellenenId) {
                          if (guncellenenId != 0) {
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    }
                  },
                  child: Text("Kaydet"),
                  color: Colors.blueAccent,
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  DropdownButton<int> notOncelik() {
    return DropdownButton<int>(
      items: _oncelik.map((e) {
        return DropdownMenuItem<int>(
            child: Text(e),
            //değer olarak index sırasına bakıp o değeri yazdırıcak
            value: _oncelik.indexOf(e));
      }).toList(),
      onChanged: (deger) {
        setState(() {
          secilenOncelik = deger ?? 0;
        });
      },
      value: secilenOncelik,
    );
  }

  List<DropdownMenuItem<int>> kategoriItems() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              child: Text(
                kategori.kategoriBaslik.toString(),
                style: const TextStyle(fontSize: 16),
              ),
              value: kategori.kategoriId,
            ))
        .toList();
  }
}
