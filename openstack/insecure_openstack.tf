# File: insecure_openstack.tf

provider "openstack" {
  auth_url    = "http://example.com:5000/v3"
  tenant_name = "admin"
  user_name   = "admin"
  password    = "changeme" # ❌ Hardcoded secret
  domain_name = "default"
  insecure    = true        # ❌ Disable TLS verification
}

resource "openstack_compute_instance_v2" "insecure_vm" {
  name            = "insecure-vm"
  image_name      = "ubuntu-20.04"
  flavor_name     = "m1.small"
  key_pair        = "default"        # ❌ Using default key pair
  security_groups = ["default"]      # ❌ Security group allows wide access

  network {
    name = "public"                  # ❌ Public network without restrictions
  }

  metadata = {
    ssh_user = "ubuntu"
    role     = "web"
  }
}

resource "openstack_networking_floatingip_v2" "bad_fip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.bad_fip.address
  instance_id = openstack_compute_instance_v2.insecure_vm.id
}
