/// Hosts that may sit behind Hostinger hCDN browser checks.
bool isLoqmaApiHost(String host) {
  final h = host.toLowerCase();
  return h == 'loqma.af' ||
      h == 'www.loqma.af' ||
      h == 'api.loqma.af' ||
      h.endsWith('.loqma.af') ||
      h == 'loqma.delivery' ||
      h == 'www.loqma.delivery' ||
      h.endsWith('.loqma.delivery');
}
