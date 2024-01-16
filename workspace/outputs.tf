output "pi_workspace_id" {
  value = resource.ibm_pi_workspace.workspace.id
}

output "pi_workspace_crn" {
  value = data.ibm_pi_workspace.workspace_data.pi_workspace_details.crn
}