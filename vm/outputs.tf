output "bootstrap_ip" {
  value = ibm_pi_instance.bootstrap[0].pi_network[*]
}
output "clusternode_ip" {
  value = ibm_pi_instance.cluster_node[0].pi_network[*]
}