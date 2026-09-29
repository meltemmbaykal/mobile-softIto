void main() {
  final Set<String> mevcutServisler = {"Servis1", "Servis2", "Servis3"};
  const bool isProduction = true;

  final List<String> tumServisler = [
    ...mevcutServisler,
    if (isProduction) "vault-secret-manager",
  ];

  print("Liste: ($tumServisler):");
}
