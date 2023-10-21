locals {
  paths = concat(var.root ? [] : [var.name], var.extra_paths)
}

resource "kubernetes_manifest" "pull_secret" {
  count = var.private ? 1 : 0
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
    }, var.private ? {"clientSecretName" = "${var.name}-pull-secret"}: {})
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