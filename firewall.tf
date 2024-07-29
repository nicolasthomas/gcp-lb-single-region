# Basic Network Firewall Rules | network-firewall.tf  

# Allow http
resource "google_compute_firewall" "allow-http" {

  name    = "${var.app-name}-fw-allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["http-server"]
  source_ranges = ["0.0.0.0/0"]

}

# allow https
resource "google_compute_firewall" "allow-https" {
  name      = "${var.app-name}-fw-allow-https"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags   = ["https-server"]
  source_ranges = ["0.0.0.0/0"]
}

# allow ssh
resource "google_compute_firewall" "allow-ssh" {
  name      = "${var.app-name}-fw-allow-ssh"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}

# allow health check
resource "google_compute_firewall" "allow-lb-health-check" {
  name      = "${var.app-name}-fw-allow-health-check"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["lb-health-check"]



  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]
}

# allow internal icmp for internal subnet
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.app-name}-fw-allow-icmp-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet
  ]
}
