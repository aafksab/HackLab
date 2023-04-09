terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
  token = ""
}

resource "random_integer" "label_suffix" {
  min = 100
  max = 999
}

resource "linode_instance" "hacklab" {
 # backup_id = "246972250"
  image = "private/19751928"
  label = "hacklab-${random_integer.label_suffix.result}"
  group = "Terraform"
  region = "us-central"
  type = "g6-standard-2"
  booted = true
  resize_disk = true
}
