# **To be execute in Google Cloud Shell**

**Create mynetwork and its resources**

- Navigate to [Zone](https://www.cloudskillsboost.google/focuses/19098?parent=catalog#:~:text=Terraform%20determined%20that%20the%20following%204%20resources%20need%20to%20be%20added%3A
) and get values of `ZONE_1` & `ZONE_2`
```
ZONE_1=
```

```
ZONE_2=
```

```
cat <<'EOF'> main.tf
# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
  auto_create_subnetworks = "true"
}

# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
  name = "mynetwork-allow-http-ssh-rdp-icmp"
  network = google_compute_network.mynetwork.self_link
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# Define the mynet-us-vm instance
resource "google_compute_instance" "mynet-us-vm" {
  name         = "mynet-us-vm"
  zone         = "Zone_1"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.mynetwork.self_link
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}

# Define the mynet-eu-vm instance
resource "google_compute_instance" "mynet-eu-vm" {
  name         = "mynet-eu-vm"
  zone         = "Zone_2"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.mynetwork.self_link
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
EOF

sed -i "s/Zone_1/$ZONE_1/g" main.tf
sed -i "s/Zone_2/$ZONE_2/g" main.tf

terraform init
terraform apply -lock=false -auto-approve
```

## Lab Completed🎉