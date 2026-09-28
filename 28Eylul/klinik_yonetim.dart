//1.Enumları (derleme Zamanı güvenliği)
enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }

enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }

//Danışan (Müşteri) Modeli
class Danisan {
  final String id;
  final String adSoyad;
  final String telefon;
  final bool vipUyeMi;
  final List<String> alerjiler; //boş olabislir ama null olamaz
  final String? ozelCiltNotu; //Opsiyonel Null Olabilir.

  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false,
    this.alerjiler = const [],
    this.ozelCiltNotu,
  });

  bool get hassasCiltMi => alerjiler.isNotEmpty;

  //Bilgi Özet Kartı
  String get bilgiOzeti {
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(',')}";
    final String notBilgisi = ozelCiltNotu ?? "Özel Medikal Not Girilmemiş";
    final String vipRozeti = vipUyeMi ? "VİP" : "STANDART";
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi ";
  }
}

//Seans (Randevu) Modeli

class SeansKaydi {
  final String seansKodu;
  final Danisan danisan;
  final HizmetKategorisi kategori;
  final String islemAdi;
  final double birimFiyat;
  final int seansSayisi;
  final double indirimOrani; //örn 10.0
  final String? sorumluUzman;
  SeansDurumu durum;
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
    this.durum = SeansDurumu.bekliyor,
    this.odemeTipi,
  });

  double get brutTutar => birimFiyat * seansSayisi;

  double get indirimTutari {
    double toplamOran = indirimOrani;
    if (danisan.vipUyeMi) {
      toplamOran += 10.0;
    }
    return brutTutar * (toplamOran / 100.0);
  }

  double get netTutar => brutTutar - indirimTutari;
}

//Yönetim Servisi
class KlinikYoneticisi {
  final String subeAdi;
  final List<SeansKaydi> _seanslar = [];
  final Map<String, Danisan> _danisanRehberi = {};

  KlinikYoneticisi({required this.subeAdi});

  //Danışan Kaydetme (Müşteri)
  void danisanKaydet(Danisan danisan) {
    _danisanRehberi[danisan.id] = danisan;
    print(
      "Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VIP" : "Standart"})",
    );
  }

  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans);
    print(
      "Randevu Kaydedildi [${seans.seansKodu}]:${seans.danisan.adSoyad} --> ${seans.islemAdi}",
    );
  }

  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.tamamlandi;
        seans.odemeTipi = odeme;
        print(
          "Seans Tamamlandı: [${seans.seansKodu}] : ${seans.netTutar.toStringAsFixed(2)} tahsil edildi. (${odeme.name})",
        );
      }
    }
    print("Hata [${seansKodu}] kodlu seans bulunamadı");
    return;
  }

  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.iptalEdildi;
        print(
          "Seans İptal Edildi [${seans.seansKodu}] : ${iptalNedeni ?? "Gerekçe Belirtilmedi"}",
        );
        return;
      }
    }
  }

  //Finansal Rapor MEtodları (fonksiyonel dart)

  double get toplamTahsilEdilenCiro => _seanslar
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  double get beklenenPotansiyelCiro => _seanslar
      .where(
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      )
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  //Kategori bazlı seans sayıları
  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    final Map<HizmetKategorisi, int> dagilim = {};
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0;
    }
    for (var s in _seanslar) {
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
    }
    return dagilim;
  }

  Set<String> gorevliUzmanKadrosu() {
    return _seanslar.map((s) => s.sorumluUzman).whereType<String>().toSet();
  }

  //Uzmansız Kalan Senaryolar
  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar.where((s) => s.sorumluUzman == null).toList();
  }

  void gunSonuRaporuYazdir() {
    print("Günlük Seans ve İşlem Çizelgesi");
    print("------------------------------------");
    print(
      "${'Kod'.padRight(10)} |"
      "${'Danışan'.padRight(16)} |"
      "${'İşlem'.padRight(20)} |"
      "${'Uzman'.padRight(18)} |"
      "${'Tutar'.padRight(10)} |"
      "${'Durum'} | ",
    );
    print("------------------------");

    for (var s in _seanslar) {
      final String uzman = s.sorumluUzman ?? "Nöbetçi Bekliyor";
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      };
      print(
        "${s.seansKodu.padRight(10)} | "
        "${s.danisan.adSoyad.padRight(10)} | "
        "${s.islemAdi.padRight(10)} | "
        "${uzman.padRight(10)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "
        "$durumRozet",
      );
    }

    print("-----------------------------------------------------------------");
    print("Finansal Özet");
    print(
      " * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}",
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
  print("Klinik Yönetim Sistemi Başlatılıyor........");
  final yonetici = KlinikYoneticisi(subeAdi: "SofIto Bağcılar Şubesi");

  //danışanları oluşturalım.
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

  //Randevu Oluşturuluyor
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
  yonetici.gunSonuRaporuYazdir();
}
