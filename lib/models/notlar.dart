class Not {
  int? notId;
  String? kategoriBaslik;
  int? kategoriId;
  String? notBaslik;
  String? notIcerik;
  String? notTarih;
  int? notOncelik;
  Not(
    this.kategoriId,
    this.notBaslik,
    this.notIcerik,
    this.notTarih,
    this.notOncelik,
  );

  Not.withId(this.notId, this.kategoriId, this.notBaslik, this.notIcerik,
      this.notTarih, this.notOncelik);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["notId"] = notId;
    map["kategoriId"] = kategoriId;
    map["notBaslik"] = notBaslik;
    map["notIcerik"] = notIcerik;
    map["notTarih"] = notTarih;
    map["notOncelik"] = notOncelik;
    return map;
  }

  Not.fromMap(Map<String, dynamic> map) {
    notId = map["notId"];
    kategoriBaslik = map["kategoriBaslik"];
    kategoriId = map["kategoriId"];
    notBaslik = map["notBaslik"];
    notIcerik = map["notIcerik"];
    notTarih = map["notTarih"];
    notOncelik = map["notOncelik"];
  }

  @override
  String toString() {
    return 'Not(notId: $notId, kategoriId: $kategoriId, notBaslik: $notBaslik, notIcerik: $notIcerik, notTarih: $notTarih, notOncelik: $notOncelik)';
  }
}
