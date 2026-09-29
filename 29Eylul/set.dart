//Set ve Ağ Güvenlik Kümeleri

void main() {
  print("Beyaz Liste ve Küme Analizi");

  final Set<String> istanbulVeriMerkeziIpleri = {
    "10.0.1.10",
    "10.0.1.11",
    "10.0.1.12",
    "10.0.1.13",
    "10.0.1.10", //Çift kayıt set burayı anında tek hale getirir.Veri tekrarı olmaz
  };
  print("İstanbul İpleri: $istanbulVeriMerkeziIpleri");

  final Set<String> frankfurtVeriMerkeziIpleri = {
    "10.0.1.13",
    "10.0.1.30",
    "10.0.1.45",
  };
  print("Frankfur İpleri: $frankfurtVeriMerkeziIpleri");

  final ortakKopruIpler = istanbulVeriMerkeziIpleri.intersection(
    frankfurtVeriMerkeziIpleri,
  );
  print("Ortak Ağ İpleri(kesişim): $ortakKopruIpler");

  final tumGlobalIpler = istanbulVeriMerkeziIpleri.union(
    frankfurtVeriMerkeziIpleri,
  );
  print(
    "Toplam Global İpler(birleşim): $tumGlobalIpler",
  ); //Farklı olanlar gelir aynısından iki tane olmaz

  final sadeceIstanbul = istanbulVeriMerkeziIpleri.difference(
    frankfurtVeriMerkeziIpleri,
  );
  print("Sadece İstanbul: $sadeceIstanbul");
}
