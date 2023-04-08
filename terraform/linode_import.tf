terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
  token = "1becddf5556a08ab3a263b45f536a26eb66244b48d1abb5fd47f9dcd5ef7a356"
}

resource "random_integer" "label_suffix" {
  min = 100
  max = 999
}

resource "linode_instance" "hacklab" {
  backup_id = "246972250"
  label = "hacklab-${random_integer.label_suffix.result}"
  group = "Terraform"
  region = "us-central"
  type = "g6-standard-2"
}

