output "name" {
  description = "Common Name"
  value       = local.name
}

output "environment" {
  description = "Environment Name"
  value       = local.environment
}

#output "cluster_egress_ip" {
#  description = "Node Public IP"
#  value = data.azurerm_public_ip.aks.ip_address
#}

output "client_certificate" {
  description = "Client Certificate"
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  description = "Kube Config"
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}

