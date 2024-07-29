# defines a group of virtual machines that will serve traffic for load balancing
resource "google_compute_backend_service" "this" {
  name                  = "${var.app-name}-backend-service"
  port_name             = "http"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = ["${google_compute_health_check.healthcheck.self_link}"]

  backend {
    group                 = google_compute_instance_group_manager.igm.instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }
}

# determine whether instances are responsive and able to do work
resource "google_compute_health_check" "healthcheck" {
  name               = "${var.app-name}-healthcheck"
  timeout_sec        = 10
  check_interval_sec = 10
  http_health_check {
    port = 80
  }
}
