terraform {
  required_providers {
    azurerm = {
      source  = "local/azurerm"
      version = "4.13.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}

  # Set the Az tenant and subscription I will be working from and
  # authenticate using Az CLI

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Set data source for current subscription
data "azurerm_subscription" "current" {
}

# Retrive existing policy definition
data "azurerm_policy_definition" "tagAllResources" {
  display_name = "Require a tag on resources"
}

# Create the management groups and assign the current subscriptionId to the production management group
resource "azurerm_management_group" "parent" {
  display_name = var.management_group_parent
}

resource "azurerm_management_group" "child" {
  for_each = toset(var.management_group_child)

  display_name               = each.key
  parent_management_group_id = azurerm_management_group.parent.id
  # Assign subscription only if the name is "production"
  subscription_ids = each.value == "Production" ? [data.azurerm_subscription.current.subscription_id] : []  
}

resource "azurerm_management_group_policy_assignment" "assign_policy" {
  name                 = "all-tag-policy"
  policy_definition_id = data.azurerm_policy_definition.tagAllResources.id
  management_group_id  = azurerm_management_group.parent.id

  parameters = jsonencode({
    "tagName" = {
      "value" = "environment"
      "value" = "owner"
    }
  })
}