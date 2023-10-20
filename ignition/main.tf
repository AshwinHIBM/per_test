resource "random_id" "label" {
  byte_length = "2" # Since we use the hex, the word length would double
  prefix      = "${var.vm_prefix}-"
}

locals {
  vm_id = random_id.label.hex
}

data "ignition_user" "vm_user" {
  name                = "core"
  password_hash = "$y$j9T$IJa8LyBLWb04dlb6Ofv2B1$NUXKFz6lnh6Z0n8j.EsMX7bZzXoXjPDBnsPaBFcFzT7"
}

data "ignition_file" "vm_hostname" {
  count     = var.rhcos_count
  overwrite = true
  mode      = "420" // 0644
  path      = "/etc/hostname"
  content {
    content = <<EOF
${local.vm_id}-rhcos-${count.index}
EOF
  }
}

data "ignition_config" "vm_ignition" {
  count = var.rhcos_count
  users = [data.ignition_user.vm_user.rendered]
  files = [data.ignition_file.vm_hostname[count.index].rendered]
}