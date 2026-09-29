enum CihazTipi { sensor, gateway, edgeServer, router }

class IoTCihaz {
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set<String> acikPortlar;
  final bool sslSertifikasiGecerliMi;
  final bool acikMi;

  IoTCihaz({
    required this.seriNo,
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMb,
    required this.acikPortlar,
    required this.sslSertifikasiGecerliMi,
    required this.acikMi,
  });

  bool get guvenlikAcigiVarMi =>
      !sslSertifikasiGecerliMi || acikPortlar.contains("23/TELNET");
}

class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => mesaj;
}

void cihazaBaglan(IoTCihaz cihaz) {
  if (!cihaz.acikMi) {
    throw CihazErisilemezException(
      "Erişim Hatası: ${cihaz.seriNo} (${cihaz.cihazAdi}) kapalı durumda! Bağlantı kurulamadı.",
    );
  }

  print("Bağlantı Başarılı: ${cihaz.cihazAdi} ile iletişim kuruldu.");
}

(String cihazAdi, CihazTipi tip, bool alarmDurumu)? cihazAraBySeriNo(
  List<IoTCihaz> cihazlar,
  String seriNo,
) {
  for (var cihaz in cihazlar) {
    if (cihaz.seriNo == seriNo) {
      bool alarmDurumu = cihaz.guvenlikAcigiVarMi;
      return (cihaz.cihazAdi, cihaz.tip, alarmDurumu);
    }
  }
  return null;
}

String izolasyonBolgesiGetir(CihazTipi tip) {
  return switch (tip) {
    CihazTipi.sensor => "ZONE-S",
    CihazTipi.gateway => "ZONE-G",
    CihazTipi.edgeServer => "ZONE-E",
    CihazTipi.router => "ZONE-R",
  };
}

void main() {
  final List<IoTCihaz> iotCihazlar = [
    IoTCihaz(
      seriNo: "IoT01",
      cihazAdi: "Cihaz1",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 90,
      bellekMb: 45,
      acikPortlar: {"23/TELNET"},
      sslSertifikasiGecerliMi: true,
      acikMi: true,
    ),
    IoTCihaz(
      seriNo: "IoT02",
      cihazAdi: "Cihaz2",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 44,
      bellekMb: 33,
      acikPortlar: {"21/FTP", "80/HTTP"},
      sslSertifikasiGecerliMi: true,
      acikMi: false,
    ),
    IoTCihaz(
      seriNo: "IoT03",
      cihazAdi: "Cihaz3",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 80,
      bellekMb: 85,
      acikPortlar: {"3389/RDP", "443/HTTPS", "22/SSH"},
      sslSertifikasiGecerliMi: false,
      acikMi: false,
    ),
    IoTCihaz(
      seriNo: "IoT04",
      cihazAdi: "Cihaz4",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 35,
      bellekMb: 5,
      acikPortlar: {"443/HTTPS", "3389/RDP"},
      sslSertifikasiGecerliMi: true,
      acikMi: false,
    ),
    IoTCihaz(
      seriNo: "IoT05",
      cihazAdi: "Cihaz5",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 14,
      bellekMb: 10,
      acikPortlar: {"80/HTTP"},
      sslSertifikasiGecerliMi: false,
      acikMi: true,
    ),
    IoTCihaz(
      seriNo: "IoT06",
      cihazAdi: "Cihaz6",
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 85,
      bellekMb: 27,
      acikPortlar: {"8090/GATEWAY"},
      sslSertifikasiGecerliMi: true,
      acikMi: true,
    ),
  ];

  final riskliCihazlar = iotCihazlar.where((cihaz) {
    return cihaz.guvenlikAcigiVarMi || cihaz.cpuYukYuzdesi > 85;
  }).toList();

  final int toplamBellek = iotCihazlar.fold(
    0,
    (toplam, cihaz) => toplam + cihaz.bellekMb,
  );

  print("Cihaz Arama Motoru Başlatıldı....");
  print("Riskli Cihaz Sayısı: ${riskliCihazlar.length}");
  print("----------------------------------------------");

  for (var cihaz in riskliCihazlar) {
    print(
      "** ${cihaz.seriNo} (${cihaz.cihazAdi}) | CPU: %${cihaz.cpuYukYuzdesi} | Güvenlik Açığı: ${cihaz.guvenlikAcigiVarMi ? 'Var' : 'Yok'}",
    );
  }

  print("Toplam Bellek Kullanımı: $toplamBellek MB");

  String arananSeriNo = "IoT03";
  var sonuc = cihazAraBySeriNo(iotCihazlar, arananSeriNo);

  print("----------------------------------------------");

  if (sonuc != null) {
    var (adi, tip, alarm) = sonuc;

    print("Cihaz Bulundu....");
    print("Cihaz Adı    : $adi");
    print("Cihaz Tipi   : ${tip.name}");
    print("Alarm Durumu : ${alarm ? 'DİKKAT (Riskli)' : 'Normal'}");
  } else {
    print("HATA: '$arananSeriNo' seri numaralı cihaz bulunamadı!");
  }
  print("----------------------------------------------");

  String bolge = izolasyonBolgesiGetir(iotCihazlar[2].tip);
  print("${iotCihazlar[2].cihazAdi} için İzolasyon Bölgesi: $bolge");

  print("----------------------------------------------");

  final kapaliCihaz = iotCihazlar.firstWhere((c) => !c.acikMi);
  try {
    print("${kapaliCihaz.cihazAdi} cihazına bağlanılmaya çalışılıyor...");
    cihazaBaglan(kapaliCihaz);
  } on CihazErisilemezException catch (e) {
    print("HATA YAKALANDI: $e");
  } catch (e) {
    print("Bilinmeyen bir hata oluştu: $e");
  } finally {
    print("Bağlantı denemesi tamamlandı.");
  }
}
