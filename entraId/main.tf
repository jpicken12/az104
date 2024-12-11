/*
####################################################################################################
# File: main.tf
# Description: Creates a management group structure with a top level group and adds a subscription to the production child managmenet group. 
#             
# Author: James Picken
# Created: 2024-12-03
# Last Updated: 2024-12-03
#
# Repository: https://github.com/jpicken12/az104
# Version: <Optional version tag or note to align with Git releases>
#
# Notes:
# - This file is part of a Terraform project used for working on Scott Duffy's az104 certification prep course
# - I only have 1 azure subscription at this time and have assigned this to the production child management group.
####################################################################################################
*/
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
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

# Set data sources for management groups and subscription
data "azurerm_subscription" "current" {
}

data "azurerm_management_group" "production" {
  display_name = "Production"
}

# Retrive existing policy definition
data "azurerm_policy_definition" "tagAllResources" {
  display_name = "Require a tag on resources"
}

# Create the management groups and assign the provided subscriptionId to the production management group
resource "azurerm_management_group" "parent" {
  display_name = var.management_group_parent
}

resource "azurerm_management_group" "child" {
  for_each = var.management_group_child

  display_name               = each.key
  parent_management_group_id = azurerm_management_group.parent.id
}

# Associate subscriptionId with production managment group
resource "azurerm_management_group_subscription_association" "mgmt_group_assoc" {
  management_group_id = data.azurerm_management_group.production.id
  subscription_id     = data.azurerm_subscription.current.id
}

resource "azurerm_management_group_policy_assignment" "assign_policy" {
  name                 = "all-tag-policy"
  policy_definition_id = data.azurerm_policy_definition.tagAllResources.id
  management_group_id  = azurerm_management_group.parent.id

  parameters = jsonencode({
    "tagName" = {
      "value" = "course title"
    }
  })
}