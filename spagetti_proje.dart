
/*

ESKİ KOD:

--SRP İHLALİ: Urun sınıfı hem verileri tutuyor, aynı anda kargoUcretiHesapla() fonksiyonu ile kargo ücretini hesaplatıyor.
   Bunları ayrı sınıflara almamız gerekmektedir.(KargoHesapla oluşturuldu) 

--LSP (Liskov Substitution Principle) İHLALİ: Dijital urunlerde kargo hesaplanmaz. 
Bu yüzden override edip Exception fırlatmak yerine ayri bir sinif olarak düzeltilmelidir. Fiziksel ürün içinde ayrı bir hesaplama yapılmalıdır.

*/


//CLEAN KOD:

class Urun {
  String id;
  String ad;
  double fiyat;
  int stok;
  String tip;

  Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);
}

abstract class KargoHesapla {
  double kargoUcretiHesapla();
}

class FizikselUrun extends Urun implements KargoHesapla {
  FizikselUrun(String id, String ad, double fiyat, int stok)
       : super(id, ad, fiyat, stok, "FIZIKSEL");

  @override
  double kargoUcretiHesapla() {
    return 29.90;
  }
}

class DijitalUrun extends Urun {
  DijitalUrun(String id, String ad, double fiyat, int stok)
      : super(id, ad, fiyat, stok, "DIJITAL");
}



/*

ESKİ KOD:

--ISP(Şişkin Arayüz) İHLALİ:
ISiparisIslemleri arayüzü tek bir çatı altında 6 farklı sorumluluğu (Veritabanı, Ödeme, Kargo, Mail, SMS, Fatura) toplamıştır.
Kargo veya SMS kullanmak istemeyen başka bir sipariş yöneticisi; ISiparisIslemleri sınıfına kargoGonder veya smsGonder metodlarını zorunlu olarak override etmek zorunda kalacaktır.
Bu sebeple bunları ayırmalıyız kullanıcı hangisini isterse onu çağırır.

*/

//CLEAN:

abstract class ISiparisKaydi {
  void siparisKaydet(String orderId, double tutar);
}

abstract class IOdemeServisi {
  void odemeYap(double tutar);
}

abstract class IKargoServisi {
  void kargoGonder(String orderId, String adres);
}

abstract class IMailServisi {
  void mailGonder(String email, String mesaj);
}

abstract class ISmsServisi {
  void smsGonder(String tel, String mesaj);
}

abstract class IFaturaServisi {
  void faturaYazdir(String orderId);
}


/*
DIP İHLALİ:
SiparisYoneticisi sınıfı, alt servisleri (SqliteVeritabani, SmtpMailServisi, NetgsmSmsServisi) kendi içinde 'new' diyerek oluşturmuştur, bağımlılık vardır. 
Veritabanı veya SMS firması değiştiğinde bu sınıfın kodlarını değiştirmek gerekir.
*/

class SqliteVeritabani implements ISiparisKaydi {
  @override
  void siparisKaydet(String orderId, double tutar) {
    print("DB calistirildi: INSERT INTO siparisler VALUES ('$orderId', $tutar)");
  }
}

class SmtpMailServisi implements IMailServisi {
  @override
  void mailGonder(String email, String mesaj) {
    print("SMTP Mail gonderildi: $email");
  }
}

class NetgsmSmsServisi implements ISmsServisi {
  @override
  void smsGonder(String tel, String mesaj) {
    print("SMS iletildi: $tel");
  }
}

// Ana sınıf sadece arayüzleri tanıyor
class SiparisYoneticisi {
  final ISiparisKaydi veritabani;
  final IMailServisi mailServisi;
  final ISmsServisi smsServisi;

  // Bağımlılıklar artık dışarıdan veriliyor
  SiparisYoneticisi(this.veritabani, this.mailServisi, this.smsServisi);

  void siparisKaydet(String orderId, double tutar) {
    veritabani.siparisKaydet(orderId, tutar);
  }

  void mailGonder(String email, String mesaj) {
    mailServisi.mailGonder(email, mesaj);
  }

  void smsGonder(String tel, String mesaj) {
    smsServisi.smsGonder(tel, mesaj);
  }
}


/*
OCP İHLALİ:
odemeYap metodu içinde if-else blokları kullanılmıştır.
Yeni bir ödeme yöntemi geldiğinde bu sınıfa girip else-if eklemek gerekir. Çalışan mevcuttaki koda müdahale edildiği için OCP ihlal edilmiştir.
*/

abstract class OdemeServisi {
  void odemeYap(double tutar);
}

class KrediKartiOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kredi kartından POS ile çekildi.");
  }
}

class HavaleOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Havale kontrol edildi.");
  }
}

class KapidaOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kapıda ödeme tahsil edilecek.");
  }
}

class CryptoOdeme implements OdemeServisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL USDT transferi onaylandı.");
  }
}



  @override
  void kargoGonder(String orderId, String adres) {
    print("MNG Kargo takip fis basildi: $adres");
  }

  @override
  void mailGonder(String email, String mesaj) {
    mailci.mailAt(email, mesaj);
  }

  @override
  void smsGonder(String tel, String mesaj) {
    smsci.smsYolla(tel, mesaj);
  }

  @override
  void faturaYazdir(String orderId) {
    print("Fatura PDF cikarildi: $orderId");
  }



    void siparisTamamla(
      String orderId,
      List<Urun> sepet,
      String odemeTipi,
      String musteriAdi,
      String email,
      String tel,
      String adres,
      String kuponKodu) {
    
    double toplam = 0;

    for (var i = 0; i < sepet.length; i++) {
      if (sepet[i].stok <= 0) {
        print("Hata: " + sepet[i].ad + " tukenmis!");
        return;
      }
      toplam += sepet[i].fiyat;
      toplam += sepet[i].kargoUcretiHesapla();
      sepet[i].stok--;
    }   

    /*
    OCP İHLALİ:
    İndirimler için if-else blokları kullanılmıştır.
    Yeni bir indirim türü geldiğinde bu sınıfa girip else-if eklemek gerekir. Çalışan mevcuttaki koda müdahale edildiği için OCP ihlal edilmiştir.
    */

    abstract class IIndirimStratejisi {
        double indirimUygula(double tutar);
    }

    class YuzdeTenIndirim implements IIndirimStratejisi {
        @override double indirimUygula(double tutar) => tutar * 0.90;
    }

    class IndirimYok implements IIndirimStratejisi {
        @override double indirimUygula(double tutar) => tutar;
    }



    double kdv = toplam * 0.20;
    double sonTutar = toplam + kdv;

    odemeYap(odemeTipi, sonTutar);
    siparisKaydet(orderId, sonTutar);
    faturaYazdir(orderId);
    mailGonder(email, "Sayin $musteriAdi, siparisiniz alindi. Tutar: $sonTutar TL");
    smsGonder(tel, "Siparisiniz onaylandi: $orderId");
    kargoGonder(orderId, adres);
  }


void main() {
  // 1. Servislerin Hazırlanması
  ISiparisKaydi veritabani = SqliteVeritabani();
  IMailServisi mailServisi = SmtpMailServisi();
  ISmsServisi smsServisi = NetgsmSmsServisi();
  IKargoServisi kargoServisi = MngKargoServisi();
  IFaturaServisi faturaServisi = PdfFaturaServisi();
  
  // Ödeme ve İndirim Nesnelerinin Seçimi
  IOdemeServisi odemeServisi = KrediKartiOdeme();
  IIndirimStratejisi indirimStratejisi = YuzdeTenIndirim();

  // 2. Sipariş Yöneticisinin Bağımlılıklarla Oluşturulması
  var siparisIslemcisi = SiparisIslemcisi(
    odemeServisi,
    veritabani,
    faturaServisi,
    mailServisi,
  );

  // 3. Ürünlerin Doğru Sınıflarla Tanımlanması
  var urun1 = FizikselUrun("1", "Kablosuz Mouse", 450.0, 5);
  var urun2 = DijitalUrun("2", "Flutter Kursu E-Kitap", 150.0, 100);

  var sepet = <Urun>[urun1, urun2];

  // 4. Siparişin Güvenli Şekilde Tamamlanması
  siparisIslemcisi.siparisIsle(
    orderId: "SP-9921",
    sepet: sepet,
    indirim: indirimStratejisi,
    email: "selahaddin@kodvance.com",
    musteriAdi: "Selahaddin",
  );
}