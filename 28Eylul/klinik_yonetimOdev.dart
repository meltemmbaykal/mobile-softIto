//1.Enumları (derleme Zamanı güvenliği)
//Kodda kullanılacak sabit değerleri gösterir. Böylece sisteme sadece belirlenen bu bilgilerin girilmesini garanti eder.
enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }

enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }

//Danışan (Müşteri) Modeli
//Danışana ait verileri ve davranışları modelleyen bir nesne yapısıdır.
//Müşteri verilerini tek bir çatı altında toplayarak uygulama genelinde dzenli bir şekilde taşınmasını sağlar.
//final ile değerin yanlızca bir kere atanabileceği değiştirilemez olduğunu belirlemek için kullanılır.
//Hassas verilerin yanlışlıkla kodun başka bir yerinde ezilmesini vey değiştirilmesini engeller.
class Danisan {
  final String id;
  final String adSoyad;
  final String telefon;
  final bool vipUyeMi;
  final List<String>
  alerjiler; //boş olabislir ama null olamaz. Metin liste şeklinde listelenir.
  final String? ozelCiltNotu; // ? sayesinde Opsiyonel Null Olabilir.

  //Danisan sınıfının yapıcı (constructor) metodudur; nesne oluşturulurken parametrelerin nasıl alınacağını belirler.
  //vipUyeMi varsayılan değerini false tanımlar. required ile veri girilmesi zorunlu alanları belirtir.
  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false,
    this.alerjiler = const [],
    this.ozelCiltNotu,
  });

  //alerjiler listesinde en az bir eleman olup olmadığını kontrol eder. Eğer en az bir değer varsa otomatik olarak hassasCiltMi true olur.
  bool get hassasCiltMi => alerjiler.isNotEmpty;

  //Bilgi Özet Kartı
  //Tüm detay bilgilerini tek bir metinde birleştiren get fonksiyonudur.
  String get bilgiOzeti {
    final String alerjiBilgisi =
        alerjiler
            .isEmpty //alerjiler dizisi boşsa "alerji yok" varsa alerjiler arasına virgülle birleştirir.
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(',')}";
    final String notBilgisi = ozelCiltNotu ?? "Özel Medikal Not Girilmemiş"; //eğer bu değer boşsa "not girilmemiş" yazar.
    final String vipRozeti = vipUyeMi ? "VİP" : "STANDART";
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi "; //bilgiOzeti fonksiyonu çağırıldığında bu sayıdaki değerler döner. Buradaki verileri de yukarın alır.
  }
}

//Seans (Randevu) Modeli
//Nesne oluşturulurken parametrelerin nasıl alınacağını belirler.
class SeansKaydi {
  final String seansKodu;
  final Danisan
  danisan; //danısan parametresi Danisan sınıfından uretilmiş bir nesneyi tutar.
  final HizmetKategorisi kategori;
  final String islemAdi;
  final double birimFiyat;
  final int seansSayisi;
  final double indirimOrani; //örn 10.0
  final String? sorumluUzman; //opsiyoneldir.
  SeansDurumu
  durum; //seansın anlık durumunu tutar. Değiştirilebilir/güncellenebilir.
  OdemeYontemi? odemeTipi;

  SeansKaydi({
    required this.seansKodu,
    required this.danisan,
    required this.kategori,
    required this.islemAdi,
    required this.birimFiyat,
    this.seansSayisi = 1,
    this.indirimOrani = 0.0,
    this.sorumluUzman,
    this.durum = SeansDurumu.bekliyor, //default olarak durumunu bekliyor yapar.
    this.odemeTipi,
  });

  double get brutTutar => birimFiyat * seansSayisi; //birimFiyat yada seansSayisi değiştiğinde brutTutarın eski kalmasını önlemek için get kullanılır, anlık güncel değer hesaplanır.

  double get indirimTutari {
    double toplamOran = indirimOrani;
    if (danisan.vipUyeMi) {
      //danisan bir VIP üye ise ekstra %10 indirim ekleyerek toplam indirim tutarını TL cinsinden döndürür.
      toplamOran += 10.0;
    }
    return brutTutar * (toplamOran / 100.0);
  }

  double get netTutar => brutTutar - indirimTutari; //net tutar hesaplanır.brut tutardan indirim tutarı çıkarılarak
}

//Yönetim Servisi
class KlinikYoneticisi {
  final String subeAdi;
  final List<SeansKaydi> _seanslar = []; //Oluşturulan tüm seans kayıtlarını sırayla tutan liste koleksiyonudur.
  //Başındaki alt çizgi bu listenin private olduğunu gösterir; liste dışarıdan doğrudan değiştirilemez, yalnızca sınıf içi metotlarla yönetilir.
  final Map<String, Danisan> _danisanRehberi = {}; //Key olarak müşteri ID'sini (String), Value (Değer) olarak ise Danisan nesnesini tutar.

  KlinikYoneticisi({required this.subeAdi}); //Sınıfın yapıcı metodudur.Yönetici nesnesi oluşturulurken subeAdi parametresinin verilmesini zorunlu tutar.

  //Danışan Kaydetme (Müşteri)
  void danisanKaydet(Danisan danisan) {
    _danisanRehberi[danisan.id] = danisan; //Müşterinin id değerini anahtar olarak kullanarak Danisan nesnesini rehber haritasına kaydeder. Aynı ID tekrar gelirse veriyi günceller.
    print(
      "Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VIP" : "Standart"})",
    );
  }

  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(
      seans,
    ); //Gelen seans nesnesini private olan _seanslar listesinin sonuna ekler.
    print(
      "Randevu Kaydedildi [${seans.seansKodu}]:${seans.danisan.adSoyad} --> ${seans.islemAdi}",
    );
  }

  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.tamamlandi; //Seans koduna göre ilgili randevuyu bulup durumunu "tamamlandı" yapar
        seans.odemeTipi =
            odeme; //ödeme bilgisini işleyen parametreli fonksiyondur.
        print(
          "Seans Tamamlandı: [${seans.seansKodu}] : ${seans.netTutar.toStringAsFixed(2)} tahsil edildi. (${odeme.name})",
        );
      }
    }
    print(
      "Hata [${seansKodu}] kodlu seans bulunamadı",
    ); // seansKodu yoksa hata döner
    return;
  }

  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    //Zorunlu seans kodu ve isteğe bağlı açıklama ile randevuyu iptal sürecine sokar.
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        //Aranılan seans kodunu listedekilerle eşleştirir.
        seans.durum =
            SeansDurumu.iptalEdildi; //Seansın durumunu iptalEdildi yapar.
        print(
          "Seans İptal Edildi [${seans.seansKodu}] : ${iptalNedeni ?? "Gerekçe Belirtilmedi"}",
        );
        return;
      }
    }
  }

  //Finansal Rapor MEtodları (fonksiyonel dart)

  double get toplamTahsilEdilenCiro =>
      _seanslar //durumu tamamlandi olan seansların netTutar değerlerini fold ile toplayan getter'dır.
          .where((s) => s.durum == SeansDurumu.tamamlandi)
          .fold(0.0, (toplam, s) => toplam + s.netTutar);

  double get beklenenPotansiyelCiro =>
      _seanslar //Henüz tamamlanmamış olan seansların tutarlarını fold ile toplar.
          .where(
            (s) =>
                s.durum == SeansDurumu.bekliyor ||
                s.durum == SeansDurumu.odadaIslemde,
          )
          .fold(0.0, (toplam, s) => toplam + s.netTutar);

  //Kategori bazlı seans sayıları
  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    final Map<HizmetKategorisi, int> dagilim = {}; //Hizmet kategorilerini ve bu kategorilerden kaçar adet randevu alındığını içeren bir Map döndürür.
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0; //Hiç randevusu olmayan kategorileri 0 gözükür.
    }
    for (var s in _seanslar) {
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1; // _seanslar listesini gezer ve her seansın kategorisindeki adedi 1 artırır.
    }
    return dagilim;
  }

  Set<String> gorevliUzmanKadrosu() {
    return _seanslar.map((s) => s.sorumluUzman).whereType<String>().toSet(); //Randevulardaki uzman isimlerini alır, null olanları eler ve toSet() ile benzersiz bir küme yapar.
    //Uzman kadrosunun isim listesini göstrir.
  }

  //Uzmansız Kalan Senaryolar
  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar.where((s) => s.sorumluUzman == null).toList(); //null bırakılmış olan seansları filtreler ve liste olarak döner.
  }

  void gunSonuRaporuYazdir() {
    //Bir tablo oluşturur.
    print("Günlük Seans ve İşlem Çizelgesi");
    print("------------------------------------");
    print(
      "${'Kod'.padRight(10)} |" //Tablonun sutunlarıdır. padRight ile sağ tarafına boşluk bırakır.
      "${'Danışan'.padRight(16)} |"
      "${'İşlem'.padRight(20)} |"
      "${'Uzman'.padRight(18)} |"
      "${'Tutar'.padRight(10)} |"
      "${'Durum'} | ",
    );
    print("------------------------");

    for (var s in _seanslar) {
      final String uzman = s.sorumluUzman ?? "Nöbetçi Bekliyor"; //_seanslar listesini döngüyle tarar; ?? operatörü ile atanmış uzman yoksa "Nöbetçi Bekliyor" varsayılır.
      final String durumRozet = switch (s.durum) {
        //seans varsa tm verilerin halini okunaklı bir forma dönüştürür.
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      };
      print(
        //Her bir seansın verilerini tablo sütun alanlarına uygun hizalayarak satır satır basar.
        "${s.seansKodu.padRight(10)} | "
        "${s.danisan.adSoyad.padRight(10)} | "
        "${s.islemAdi.padRight(10)} | "
        "${uzman.padRight(10)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "
        "$durumRozet",
      );
    }

    print("-----------------------------------------------------------------");
    print(
      "Finansal Özet",
    ); //getter hesaplamalarını ve toplam randevu sayısını ekrana yazdırır.
    print(
      " * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}", //toStringAsFixed metodu, ondalıklı sayıları metne  dönüştürür.
      //Virgülden sonra 2 basamak gösterileceğini sabitlemek için kullanılır.
    );
    print(
      " * Bekleyen Potansiyel Alacak: ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
    );
    print(" * Toplam Seans: ${_seanslar.length} Randevu");
    print("-----------------------------------------------------------------");
    print("Aktif Uzmanlar");
    final uzmanlar = gorevliUzmanKadrosu();
    if (uzmanlar.isEmpty) {
      print("Kayıtlı Uzman Bulunamadı");
    } else {
      print(" ${uzmanlar.join(',')}");
    }
    final uzmansizlar = uzmansizSeanslariGetir();
    if (uzmansizlar.isNotEmpty) {
      print(
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır.",
      );
      for (var u in uzmansizlar) {
        print("->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
      }
    }
    print("-----------------------------------------------------------------");
  }
}

void main() {
  //// Çalıştırılacak kodlar buraya yazılıyor.
  print("Klinik Yönetim Sistemi Başlatılıyor........");
  final yonetici = KlinikYoneticisi(subeAdi: "SofIto Bağcılar Şubesi");

  //danışanları oluşturuldu tek tek içine alabileceği değerler girildi. Required olan alanlar mutlaka girildi.
  final d1 = Danisan(
    id: "DAN-101",
    adSoyad: "Ahmet Yılmaz",
    telefon: "0555 555 540 45 67",
    vipUyeMi: true,
    alerjiler: ["Retinol, Aspirin"],
    ozelCiltNotu: "Cilt Bariyeri hassas",
  );

  final d2 = Danisan(
    id: "DAN-102",
    adSoyad: "Ahmet Yılan",
    telefon: "0555 555 540 45 67",
    vipUyeMi: false,
    alerjiler: [],
  );

  final d3 = Danisan(
    id: "DAN-103",
    adSoyad: "Mehmet Yılmaz",
    telefon: "0555 555 540 45 67",
    vipUyeMi: true,
    alerjiler: ["Retinol, Aspirin"],
  );

  final d4 = Danisan(
    id: "DAN-104",
    adSoyad: "Ahmet Mehmet Yılmaz",
    telefon: "0555 555 540 45 67",
    vipUyeMi: true,
    alerjiler: [],
    ozelCiltNotu: "Cilt Bariyeri hassas",
  );

  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("Danışan Güvenlik Kontrolü");
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("-----------------------------------------------------------------");

  //Randevu Oluşturuldu  tek tek içine alabileceği değerler girildi. Required olan alanlar mutlaka girildi.
  final seans1 = SeansKaydi(
    seansKodu: "SNS-2026-1",
    danisan: d1,
    kategori: HizmetKategorisi.Lipo,
    islemAdi: "Lipo Gerisini Bilmiyorum",
    birimFiyat: 6500.0,
    seansSayisi: 2,
    indirimOrani: 5.0,
    sorumluUzman: "Sümeyye Arab",
  );
  final seans2 = SeansKaydi(
    seansKodu: "SNS-2026-2",
    danisan: d2,
    kategori: HizmetKategorisi.ciltYenileme,
    islemAdi: "Siverex ile yüz temizleme",
    birimFiyat: 2500.0,
    seansSayisi: 5,
    indirimOrani: 15.0,
    sorumluUzman: null,
  );
  final seans3 = SeansKaydi(
    seansKodu: "SNS-2026-3",
    danisan: d3,
    kategori: HizmetKategorisi.lazerEpilasyon,
    islemAdi: "Tüm Vucut",
    birimFiyat: 25000.0,
    seansSayisi: 15,
    indirimOrani: 0.0,
    sorumluUzman: "Tuba Aydın",
  );
  final seans4 = SeansKaydi(
    seansKodu: "SNS-2026-4",
    danisan: d4,
    kategori: HizmetKategorisi.medikalEstetik,
    islemAdi: "Burun Estetiği",
    birimFiyat: 1500.0,
    seansSayisi: 3,
    sorumluUzman: "Alaaddin Odabaşı",
  );

  yonetici.randevuOlustur(seans1);
  yonetici.randevuOlustur(seans2);
  yonetici.randevuOlustur(seans3);
  yonetici.randevuOlustur(seans4);
  print("Seanslar Gönderiliyor");

  //seans 1 başarıyla tamamlanıyor (Kredi kartı ile Ödeme);
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-1",
    odeme: OdemeYontemi.krediKarti,
  );
  //seans 2 başarıyla tamamlanıyor (Nakit ile Ödeme);
  yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);

  //seans 4 iptal ediliyor
  yonetici.seansiIptalEt(
    "SNS-2026-04",
    iptalNedeni: "Danışanın şehir dışından tanıdığı geldiği için gelemedi",
  );
  yonetici.gunSonuRaporuYazdir(); //bunun sayesinde tüm fonksiyonlar adım adım ilerleyerek çıktılar oluşturulur.
}
