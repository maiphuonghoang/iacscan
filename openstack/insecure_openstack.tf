provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "plaintext-password" # [1] Hardcoded password
  auth_url    = "http://openstack.local:5000/v3" # [2] Insecure HTTP
  domain_name = "default"
  insecure    = true # [3] TLS verification disabled
}

resource "openstack_compute_keypair_v2" "bad_key" {
  name       = "default"
  public_key = file("~/.ssh/id_rsa.pub") # [4] Local SSH key file exposed
}

resource "openstack_networking_secgroup_v2" "open_sg" {
  name        = "open-all"
  description = "Allow all inbound traffic" # [5] Overly permissive rule
}

resource "openstack_networking_secgroup_rule_v2" "allow_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 0
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0" # [6] Wide-open access
  security_group_id = openstack_networking_secgroup_v2.open_sg.id
}

resource "openstack_compute_instance_v2" "vm1" {
  name            = "insecure-vm"
  image_name      = "cirros"
  flavor_name     = "m1.small"
  key_pair        = openstack_compute_keypair_v2.bad_key.name
  security_groups = [openstack_networking_secgroup_v2.open_sg.name]

  network {
    name = "public" # [7] Publicly accessible
  }

  user_data = file("startup.sh") # [8] No validation or checksum
}

resource "openstack_blockstorage_volume_v2" "unprotected_volume" {
  name = "vol1"
  size = 10
  # [9] No encryption
}

resource "openstack_compute_volume_attach_v2" "attach" {
  instance_id = openstack_compute_instance_v2.vm1.id
  volume_id   = openstack_blockstorage_volume_v2.unprotected_volume.id
}

resource "openstack_compute_instance_v2" "vm2" {
  name       = "no-metadata"
  image_name = "cirros"
  flavor_name = "m1.tiny"

  network {
    name = "public"
  }
  # [10] Missing metadata
}

output "vm_password" {
  value = "super-secret-password" # [11] Outputting secrets
}

variable "vm_token" {
  default = "1234567890abcdef" # [12] Secret in default var
}

resource "null_resource" "debug" {
  provisioner "local-exec" {
    command = "echo Sensitive Debug Info: ${var.vm_token}" # [13] Leak via debug
  }
}
# ./bin/kics scan -p "D:\ci-cd\iacscan\openstack" --report-formats json -o "./results2