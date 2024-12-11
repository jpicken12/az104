terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }
}

/*provider "azurerm" {
  # Configuration options
  features {}

  # Set the Az tenant and subscription I will be working from and
  # authenticate using Az CLI

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}*/

# Retrive existing policy definition
data "azurerm_policy_definition" "tagAllResources" {
  display_name = "Require a tag on resources"
  #  type = "BuiltIn"
}
/*
resource "azurerm_management_group_policy_assignment" "tagAllResources" {
  name                 = "tag_all_resources - policy"
  policy_definition_id = data.azurerm_policy_definition.tagAllResources
  management_group_id  = azurerm_management_group.parent.id
}

resource "azurerm_policy_definition" "tagAllResources" {
  name                = "tagAllResourcesPolicy"
  policy_type         = "BuiltIn"
  mode                = "Indexed"
  display_name        = "Add a tag to resources"
  description         = "Adds the specified tag and value when any resource missing this tag is created or updated. Existing resources can be remediated by triggering a remediation task. If the tag exists with a different value it will not be changed. Does not modify tags on resource groups."
#  management_group_id = azurerm_management_group.parent.id

  metadata = <<METADATA
    {
      "category":"Tags"
    }
METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
        },
        "then": {
        "effect": "modify",
        "details": {
        "roleDefinitionIds": [
          "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
        "operations": [
          {
            "operation": "add",
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "value": "[parameters('tagValue')]"
            }
          ]
        }
      }
    }
POLICY_RULE

  parameters = <<PARAMETERS
    {
      "tagName": {
        "type": "String",
        "metadata": {
          "description": "Name of the tag, such as 'environment'",
          "displayName": "Tag Name"
        }
      },
    "tagValue": {
      "type": "String", 
      "metadata": {
        "description": "Value of the tag, such as 'production'",
        "displayName": "Tag Value"
      }
    }
  }
PARAMETERS
*/