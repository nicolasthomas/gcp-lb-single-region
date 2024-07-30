resource "google_dns_record_set" "a" {
  name         = "${var.subdomain}.${google_dns_managed_zone.zonedns.dns_name}"
  managed_zone = google_dns_managed_zone.zonedns.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_forwarding_rule.https.ip_address]
}

resource "google_dns_record_set" "aaaa" {
  name         = "${var.subdomain}.${google_dns_managed_zone.zonedns.dns_name}"
  managed_zone = google_dns_managed_zone.zonedns.name
  type         = "AAAA"
  ttl          = 300

  rrdatas = [google_compute_global_forwarding_rule.https-v6.ip_address]
}

resource "google_dns_managed_zone" "zonedns" {
  name     = replace("${var.domain}", ".", "-")
  dns_name = "${var.domain}."
}
