terraform {
  required_version = ">= 0.13"
  required_providers {
    acme = {
      source = "vancluever/acme"
    }
    aws = {
      source = "hashicorp/aws"
    }
    http = {
      source = "hashicorp/http"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
