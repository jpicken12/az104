/*
####################################################################################################
# File: main.tf
# Description: Creates a cost management budget at the subscription scope, currently hardcoded to 20. Sets several
#             actual and forecast notifications which send an e-mail via an action group to help prevent overspend.
# Author: James Picken
# Created: 2024-11-28
# Last Updated: 2024-11-28
#
# Repository: https://github.com/jpicken12/az104
# Version: <Optional version tag or note to align with Git releases>
#
# Notes:
# - This file is part of a Terraform project used for working on Scott Duffy's az104 certification prep course
# - Could consider increading variable usage, i.e. for amount and possibly moving some of this to modules
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

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "az104" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_monitor_action_group" "email" {
  name                = "alert"
  resource_group_name = azurerm_resource_group.az104.name
  short_name          = "alertActon"

  email_receiver {
    name          = "sendToOwner"
    email_address = var.email_address
  }
}

resource "azurerm_consumption_budget_subscription" "budget" {
  name            = "spendingTooMuch"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 20
  time_grain = "Monthly"

  time_period {
    start_date = "2024-11-01T00:00:00Z" # must be 1st of month
    end_date   = "2026-11-30T00:00:00Z"
  }

  notification {
    enabled   = true
    threshold = 100.0
    operator  = "EqualTo"

    contact_groups = [
      azurerm_monitor_action_group.email.id,
    ]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_groups = [
      azurerm_monitor_action_group.email.id,
    ]
  }

  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThan"

    contact_groups = [
      azurerm_monitor_action_group.email.id,
    ]
  }
}