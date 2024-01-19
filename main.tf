locals {
  region                = "eastus"
  environment           = "lab"
  name                  = "llage"
  address_space         = ["10.10.0.0/16"]
  subnet_address_prefix = ["10.10.0.0/20"]
  network_plugin        = "azure" # You can choose "kubenet" or "azure"
  k8s_version           = "1.27"  # don't specify the patch version!
  node_size             = "Standard_E4as_v5"
}


resource "azurerm_resource_group" "rg" {
  name     = format("rg-%s-%s", local.environment, local.name)
  location = local.region

  tags = {
    environment = local.environment
  }
}

resource "azurerm_virtual_network" "vnet" {  
  address_space       = local.address_space
  location            = local.region
  name                = format("vnet-%s", local.environment)
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]

  tags = {
    environment = local.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "aks-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = local.subnet_address_prefix
  depends_on           = [azurerm_virtual_network.vnet]
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = format("aks-%s", local.name)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = format("aks-%s", local.name)
  depends_on          = [azurerm_virtual_network.vnet]
  
  default_node_pool {
    name                  = "system"
    node_count            = 1
    vm_size               = local.node_size
    enable_node_public_ip = true
    max_pods              = 250
    vnet_subnet_id        = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = local.network_plugin
  # network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  azure_policy_enabled             = false

  tags = {
    Environment = local.environment
  }
}