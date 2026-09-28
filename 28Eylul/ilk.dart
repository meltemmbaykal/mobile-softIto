/*  
 //print("İlk Dersimiz- Dart SDK aktif olmalı");
  //1.Açık belirtilen veri tipleri
  int seansSuresiDakika=45;
  double seansUcretiTl=2750.50;
  String uzmanAdi="Dr Aygen Yıldırım";
  bool aktifMi=true; 

//2.String interpolation Jd'deki `${}` bunun yerine sadece $degisken işlem varsa ${degisken*4} kullanılır.

  print("Uzman: $uzmanAdi | Süre: $seansSuresiDakika dk | Ücret $seansUcretiTl ₺ ");
  print("KDV dahil (%20) ${seansUcretiTl*1.20} ₺");


  //3.var ile tip çıkarımı

  var tedaviAdi="Kave ile peeling";
  //tedaviAdi=99;

  //4.dynamic veri tipini bağımsız kullanabilirsiniz ancak flutterda önerilmez
 
  dynamic serbestKutu = "Lazer Epialsyon";
  serbestKutu = 1000; //izin verilir ama veri tip güvenliğini yok eder.

  //const:DErleme anında değeri belli olan veriler,bellekte tek bir yerde saklanır.
  const String KLINIK_ADI = "SofITo Güzellik Merkezi";
  const double KDV_ORANI = 0.20;

  //const DateTime suankiZaman=DateTime.now(); //Hata derleme anında bunu bilemeyiz.
  //final: Çalışma anında hesapanır, bir kere hesaplandıktan sonra değişmez

  final DateTime randevuZamani = DateTime.now();
  final String takipKodu =
      "SOFT-" + randevuZamani.microsecondsSinceEpoch.toString();

  print("Klinik Adı: $KLINIK_ADI");
  print("Oluşturulma Tarihi: $randevuZamani | Kod: $takipKodu");

  //Dartta değişken varsayılan olarak null olamaz. Bununn yerine null safety operatörlerini kullanırız.
  //(?, ??, ! gibi)

  String zorunluDanisanAdi = "Meltem Demir";
  String? danisanAlerjiNotu;
  print("alerji notu: $danisanAlerjiNotu");

  //ifNull operatörü- null ise varsayılan değer atama
  String goruntulenecekNot = danisanAlerjiNotu ?? "Bilinen bir alerjisi yok";
  print("RAPOR: $goruntulenecekNot ");

  //null aware
  print("alerji metin uzunluğu: ${danisanAlerjiNotu?.length}");
  
  */

//Klasik Sıralı Fonksiyon
double topla(double a, double b) => a + b;

//Modern DArt/Flutter standartları: Named parameters({})

void seansKaydiOlustur({
  required String danisan,
  required String tedavi,
  required double birimFiyat,
  int seansSayisi = 1, //default değer
  double indirimOrani = 0.0, //default değer
  String? uzmanHekim, //null olabilir
}) {
  final double brutTutar = birimFiyat * seansSayisi;
  final double indirimTutari = brutTutar * (indirimOrani / 100);
  final double netTutar = brutTutar - indirimTutari;

  print("""

===================================

SoftIto Seans Sözleşmesi 

-----------------------------

Danışan        : $danisan
Tedavi         : $tedavi (x$seansSayisi Seans)
Uzman Hekim    : ${uzmanHekim ?? "Nöbetçi Estetisyen"}
Brüt Tutar     : $brutTutar ₺
İndirim        : -$indirimTutari ₺ ($indirimOrani)
Ödenecek Tutar : $netTutar ₺

===================================
""");
}

void main() {
  seansKaydiOlustur(
    danisan: "Sümeyye Muhammed",
    tedavi: "Medikal Cilt Yenileme",
    birimFiyat: 4500.0,
    seansSayisi: 3,
    indirimOrani: 15.0,
    uzmanHekim: "Dr.Shahd",
  );
}
