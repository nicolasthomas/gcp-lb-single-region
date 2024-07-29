resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "${google_dns_managed_zone.zonedns.name}-ssl-cert"

  managed {
    domains = ["${var.subdomain}.${var.domain}."]
  }
}
