class Kategori {
  int? kategoriId;
  String? kategoriBaslik;

  Kategori(
    this.kategoriBaslik,
  );
  //veri tabanına veri eklerken sadece bunu kullanacağız çünkü Id değerini otomatik olrak verdiği için

  Kategori.withId(this.kategoriId, this.kategoriBaslik);
  //Veri tabanından değer okurken isimlendirilmiş constructar olan withId kullanacağız

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["kategoriId"] = kategoriId;
    map["kategoriBaslik"] = kategoriBaslik;
    return map;
    //veri tabanına yazarken map e çevirip göndermemiz lazım
  }

  Kategori.fromMap(Map<String, dynamic> map) {
    this.kategoriId = map["kategoriId"];
    this.kategoriBaslik = map["kategoriBaslik"];
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Kategori{kategoriId : $kategoriId, kategoriBaslik: $kategoriBaslik} ";
  }
}
