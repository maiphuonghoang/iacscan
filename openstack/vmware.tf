provider "virtualbox" {}

resource "virtualbox_vm" "k8s-master" {
  name   = "k8s-master"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64"
  cpus   = 2
  memory = 2048

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }

  # ❌ LỖI: hardcoded credentials, có thể bị phát hiện bởi scanner
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | sh -"
    ]
    connection {
      type     = "ssh"
      user     = "root"
      password = "123456"   # ❌ Hardcoded password (misconfiguration)
      host     = self.ipv4_address
    }
  }
}

resource "virtualbox_vm" "k8s-worker" {
  name   = "k8s-worker"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64"
  cpus   = 2
  memory = 2048

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }

  # ❌ LỖI: thiếu cấu hình giới hạn CPU, memory rõ ràng
  # ❌ LỖI: không dùng key ssh, lại hardcode password

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${virtualbox_vm.k8s-master.ipv4_address}:6443 K3S_TOKEN=mytoken sh -"
    ]
    connection {
      type     = "ssh"
      user     = "root"
      password = "123456"  # ❌ Misconfiguration: plain-text secret
      host     = self.ipv4_address
    }
  }
}
