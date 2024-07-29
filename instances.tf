# automatically scale virtual machine instances in managed instance groups according to an autoscaling policy
resource "google_compute_autoscaler" "autoscaler" {
  name   = "${var.app-name}-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.igm.self_link

  autoscaling_policy {
    max_replicas    = 8
    min_replicas    = 2
    cooldown_period = 30

    cpu_utilization {
      target = 0.72
    }
  }
}

# Create web server template
resource "google_compute_instance_template" "instance_template" {
  #name                 = "${var.app-name}-instance-template"
  machine_type         = var.instance_type
  instance_description = "server web for website"
  name_prefix          = "webserver-${var.app-name}-"
  can_ip_forward       = false
  tags                 = ["ssh", "http-server", "https-server", "lb-health-check"]

  disk {
    source_image = data.google_compute_image.debian.id
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = "${var.app-name}-network"
    subnetwork = google_compute_subnetwork.private.self_link
  }

  scheduling {
    automatic_restart   = true # false if preemtible is true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }


  metadata = {
    enable-oslogin = true
    startup-script = "sudo apt update && sudo apt install -yq nginx"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

}


resource "random_id" "group-manager-suffix" {
  byte_length = 4
}

# creates a group of virtual machine instances
resource "google_compute_instance_group_manager" "igm" {
  name = "${var.app-name}-instance-group-manager-${random_id.group-manager-suffix.hex}"
  zone = var.zone

  version {
    instance_template = google_compute_instance_template.instance_template.self_link
    name              = "primary"
  }

  #target_pools       = [google_compute_target_pool.wordpress.id]
  base_instance_name = "webserver-${var.app-name}"
  depends_on         = [google_compute_instance_template.instance_template]

  named_port {
    name = "http"
    port = 80
  }

  lifecycle {
    create_before_destroy = true
  }

}

# get last image of debian 12
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}
