output "bootstrap_ip" {
  value = local.bootstrap_ips[0]
}

output "clusternode_ip" {
  value = local.clusternode_ips[0]
}