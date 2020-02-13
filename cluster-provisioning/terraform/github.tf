# Generate a keypair. The private key will go to Flux in-cluster, public key
# will be added as a deploy key to the Github repo.

resource "tls_private_key" "flux" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "github_repository" "flux" {
  name = var.github_repository
}

resource "github_repository_deploy_key" "flux" {
  title      = "Flux deploy key (flux-${var.prefix})"
  repository = data.github_repository.flux.name
  read_only  = false
  key        = tls_private_key.flux.public_key_openssh
}