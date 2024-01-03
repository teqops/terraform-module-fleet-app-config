locals {
  paths = concat(var.root ? [] : [var.name], var.extra_paths)
  # if var.existing then pull secret from existing secret if not then "${var.name}-pull-secret"
  pull_secret_name = var.existing ? var.secret : "${var.name}-pull-secret"
}

resource "kubernetes_manifest" "pull_secret" {
  count = var.private && !var.ssh && !var.existing ? 1 : 0
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Secret"
    "type"       = "kubernetes.io/basic-auth"
    "metadata" = {
      "name"      = "${var.name}-pull-secret"
      "namespace" = "fleet-default"
    }
    "data" = {
      "password" = base64encode(var.git_password)
      "username" = base64encode(var.git_username)
    }
  }
}


resource "kubernetes_manifest" "pull_secret_ssh" {
  count = var.private && var.ssh ? 1 : 0
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Secret"
    "type"       = "kubernetes.io/basic-auth"
    "metadata" = {
      "name"      = "${var.name}-pull-secret"
      "namespace" = "fleet-default"
    }
    "data" = {
      "ssh-privatekey" = base64encode(var.ssh_key)
    }
  }
}

resource "kubernetes_manifest" "gr-cert-manager" {
  manifest = {
    "apiVersion" = "fleet.cattle.io/v1alpha1"
    "kind"       = "GitRepo"
    "metadata" = {
      "name"      = var.name
      "namespace" = "fleet-default"
    }
    "spec" = merge({
      "branch" = var.branch
      "repo" = var.repo
      "paths" = local.paths
      "targets" = [
        {
          "clusterGroup" = var.name
        }
      ]
    }, var.private ? {"clientSecretName" = "${local.pull_secret_name}"}: {})
  }
}

resource "kubernetes_manifest" "cg-cert-manager" {
  manifest = {
    "apiVersion" = "fleet.cattle.io/v1alpha1"
    "kind"       = "ClusterGroup"
    "metadata" = {
      "name"      = var.name
      "namespace" = "fleet-default"
    }
    "spec" = {
      "selector" = {
          "matchExpressions" = []
          "matchLabels" = {
            "${var.name}" = true
          }
      }
    }
  }
}