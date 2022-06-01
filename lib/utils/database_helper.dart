import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notlarim/models/kategori.dart';
import 'package:notlarim/models/notlar.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
/*
oluşturduğumuz database_helper dosyası bu şekildedir.
 */

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database?
      _database; //veri tabanı üzerinde güncelleme okuma , silme gibi işlemleri yapmamızı sağlar

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database> _initializeDatabase() async {
    Database? _db;
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "appDatabase.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notlar.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    _db = await openDatabase(path, readOnly: false);
    return _db;
  }

  Future<List<Map<String, dynamic>>> kategorilerigetir() async {
    var db = await _getDatabase();
    var sonuc = await db.query("kategori");
    return sonuc;
    //Create
  }

  Future<List<Kategori>> kategorListesiniGetir() async {
    var kategorileriIcerenMap = await kategorilerigetir();
    List<Kategori> kategoriListesi = [];
    for (Map okunanKategori in kategorileriIcerenMap) {
      kategoriListesi
          .add(Kategori.fromMap(okunanKategori as Map<String, dynamic>));
    }
    return kategoriListesi;
  }

  Future<int> kategoriEkle(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = await db.insert("kategori", kategori.toMap());
    return sonuc;
    //kategori modelimizden bir nesne yollayacağız öncelikle db oluşturucağız daha sonra hangi tabloya ekleyeceğimizi belirtiyoruz
    //tabi kategori nesnesini dönüştürmemiz lazım işte burada tomap() fonk. ile map e dönüştürüp ekleme yapıyoruz
  }

  Future<int> kategoriUpdate(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = await db.update("kategori", kategori.toMap(),
        where: "kategoriId = ?", whereArgs: [kategori.kategoriId]);
    return sonuc;

    ///öncelikle tablonun adını istiyor sonrasında güncellenmiş değerleri içeren map i istiyor sonrasında ise koşulu yazacağız neye göre
    ///güncellenecek bunu soruyor sonra soru işareti yerine gelecek olan değerimizi yazıyoruz bana parametre olarak gelen kategoriyi liste olarak
    ///istiyor whereArgs kısmı
  }

  Future<int> kategoriSil(int kategoriId) async {
    var db = await _getDatabase();
    var sonuc = await db
        .delete("kategori", where: "kategoriId = ?", whereArgs: [kategoriId]);
    return sonuc;

    ///burada ise yine tabloyu soruyor sonrasında koşulumuz yani silinecek olan ne
    ///örnek olrak burada yapılan kategori tablosunda id' si 5 olan değeri sil demek
  }

  ///////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> notlariGetir() async {
    var db = await _getDatabase();
    // var sonuc = await db.query("not", orderBy: "notId DESC"); normalde bu şekilde getirirdik fakat birbirine bağladığımız yerler var ondan dolayı
    //En son ekledğim not ilk sırada gelsin demek orderBy DESC
    var sonuc = db.rawQuery(
        'select * from "not" inner join kategori on kategori.kategoriId="not".kategoriId order by notId Desc ');

    ///burada not la beraber kategoriId de geliyor fakat sayı olarak geliyor kategori tablasunda bulunan kategoriId ye ait string ifadeyi
    ///notla beraber getirebilmem için bu ifadeyi yazdık.
    print("sonuc $sonuc");
    return sonuc;
  }

  Future<List<Not>> notListesiniGetir() async {
    var notlarMap = await notlariGetir();
    List<Not> notListesi = [];
    for (Map okunanNot in notlarMap) {
      notListesi.add(Not.fromMap(okunanNot as Map<String, dynamic>));
    }

    return notListesi;
  }

  Future<int> notlariEkle(Not not) async {
    var db = await _getDatabase();
    var sonuc = db.insert("not", not.toMap());
    return sonuc;
  }

  Future<int> notUpdate(Not not) async {
    var db = await _getDatabase();
    var sonuc = db
        .update("not", not.toMap(), where: "notId = ?", whereArgs: [not.notId]);
    return sonuc;
  }

  Future<int> notSil(int notId) async {
    var db = await _getDatabase();
    var sonuc = db.delete("not", where: "notId = ?", whereArgs: [notId]);
    return sonuc;
  }

  String dateFormat(DateTime tm) {
    DateTime today = DateTime.now();
    Duration oneDay = Duration(days: 1);
    Duration twoDay = Duration(days: 2);
    Duration oneWeek = Duration(days: 7);
    String month = "";

    switch (tm.month) {
      case 1:
        month = "Ocak";
        break;
      case 2:
        month = "Şubat";
        break;
      case 3:
        month = "Mart";
        break;
      case 4:
        month = "Nisan";
        break;
      case 5:
        month = "Mayıs";
        break;
      case 6:
        month = "Haziran";
        break;

      case 7:
        month = "Temmuz";
        break;
      case 8:
        month = "Ağustos";
        break;
      case 9:
        month = "Eylül";
        break;
      case 10:
        month = "Ekim";
        break;
      case 11:
        month = "Kasım";
        break;
      case 12:
        month = "Aralık";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Pazartesi";
        case 2:
          return "Salı";
        case 3:
          return "Çarşamba";
        case 4:
          return "Perşembe";
        case 5:
          return "Cuma";
        case 6:
          return "Cumartes";
        case 7:
          return "Pazar";
      }
    } else if (tm.year == today.year) {
      return "${tm.day} $month ";
    } else {
      return "${tm.day} $month ${tm.year} ";
    }
    return "";
  }
}
