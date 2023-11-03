# ALLOW SSH 
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
# ALLOW HTTP
resource "google_compute_firewall" "http" {
  name = "allow-http"

  allow {
    ports    = ["80"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# ALLOW HTTPS
resource "google_compute_firewall" "https" {
  name = "allow-https"

  allow {
    ports    = ["443"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "k8s-specific" {
  name = "k8s-ports"

  allow {
    ports    = ["6443","2379","2380","10250","10251","10252","10255"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["cluster-node"]
  source_tags   = ["cluster-node"]
}