resource "packet_ssh_key" "lab" {
  name       = "lab"
  public_key = "${tls_private_key.lab.public_key_openssh}"
}

resource "packet_device" "lab" {

  depends_on       = ["packet_ssh_key.lab"]

  count            = "${var.lab_count}"
  hostname         = "${format("lab%02d", count.index)}"
  operating_system = "${var.operating_system}"
  plan             = "${var.plan}"

  connection {
    user        = "root"
    private_key = "${tls_private_key.lab.private_key_pem}"
    agent       = false
    timeout     = "30s"
  }
  facilities    = ["${var.packet_facility}"]
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"

  provisioner "file" {
    source      = "install-kubectl.sh"
    destination = "install-kubectl.sh"
  }

  provisioner "file" {
    source      = "install-virtualbox.sh"
    destination = "install-virtualbox.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "ssh-keygen -A", 
#      "bash hardware-setup.sh > hardware-setup.out",
    ]
  }
}
