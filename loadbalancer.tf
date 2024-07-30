
# global ip for loadbalancer
resource "google_compute_global_address" "ip-lb" {
  name = "${var.app-name}-ipv4"
}


# global ip for loadbalancer
resource "google_compute_global_address" "ip-lb-v6" {
  name       = "${var.app-name}-ipv6"
  ip_version = "IPV6"
}


# used to forward traffic to the correct load balancer for HTTP load balancing 
resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.app-name}-http"
  target     = google_compute_target_http_proxy.http.self_link
  ip_address = google_compute_global_address.ip-lb.address
  port_range = "80"
}

# used to forward traffic to the correct load balancer for HTTP load balancing
resource "google_compute_global_forwarding_rule" "http-v6" {
  name       = "${var.app-name}-http-v6"
  target     = google_compute_target_http_proxy.http.self_link
  ip_address = google_compute_global_address.ip-lb-v6.address
  port_range = "80"
}


# used to route requests to a backend service based on rules that you define for the host and path of an incoming URL
resource "google_compute_url_map" "http" {
  name = "${var.app-name}-http"

  /*
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
  */

  default_service = google_compute_backend_service.this.id
}

# used by one or more global forwarding rule to route incoming HTTP requests to a URL map
resource "google_compute_target_http_proxy" "http" {
  name    = "${var.app-name}-http"
  url_map = google_compute_url_map.http.self_link
}


# for https trafic
resource "google_compute_url_map" "https" {
  name = "${var.app-name}-https"

  host_rule {
    hosts        = ["${var.subdomain}.${var.domain}"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.this.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.this.id
    }
  }

  default_service = google_compute_backend_service.this.id
}

resource "google_compute_target_https_proxy" "https" {
  name             = "${var.app-name}-https"
  url_map          = google_compute_url_map.https.id
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_default.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.app-name}-https"
  target     = google_compute_target_https_proxy.https.id
  ip_address = google_compute_global_address.ip-lb.address
  port_range = "443"
}

resource "google_compute_global_forwarding_rule" "https-v6" {
  name       = "${var.app-name}-https-v6"
  target     = google_compute_target_https_proxy.https.id
  ip_address = google_compute_global_address.ip-lb-v6.address
  port_range = "443"
}

# show external ip address of load balancer
output "Loadbalancer-IPv4-Address" {
  value = google_compute_global_address.ip-lb.address
}
# show external ip address of load balancer
output "Loadbalancer-IPv6-Address" {
  value = google_compute_global_address.ip-lb-v6.address
}
