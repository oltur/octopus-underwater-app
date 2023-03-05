
variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

provider "aws" {
  region     = "eu-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-west-1:916438688338:cluster/terraform-cluster-1"
  # load_config_file = false
}

# data "aws_ami" "app_ami" {
#   most_recent = true
#   owners      = ["amazon"]


#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

# resource "aws_instance" "instance-1" {
#   ami           = data.aws_ami.app_ami.id
#   instance_type = "t2.micro"
# }

resource "aws_ecr_repository" "ecr-oltur-terraform" {
  name                 = "oltur-terraform"

  # image_scanning_configuration {
  #   scan_on_push = true
  # }
}

resource "aws_eks_cluster" "terraform-cluster-1" {
    name     = "terraform-cluster-1"
    enabled_cluster_log_types = []
    role_arn                  = "arn:aws:iam::916438688338:role/eksctl-terraform-cluster-1-cluster-ServiceRole-74ADPB8PZOC6"
    tags                      = {
        "Name"                                        = "eksctl-terraform-cluster-1-cluster/ControlPlane"
        "alpha.eksctl.io/cluster-name"                = "terraform-cluster-1"
        "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
        "alpha.eksctl.io/eksctl-version"              = "0.132.0"
        "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "terraform-cluster-1"
    }
    tags_all                  = {
        "Name"                                        = "eksctl-terraform-cluster-1-cluster/ControlPlane"
        "alpha.eksctl.io/cluster-name"                = "terraform-cluster-1"
        "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
        "alpha.eksctl.io/eksctl-version"              = "0.132.0"
        "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "terraform-cluster-1"
    }
    version                   = "1.24"

    kubernetes_network_config {
        ip_family         = "ipv4"
        service_ipv4_cidr = "10.100.0.0/16"
    }

    vpc_config {
        endpoint_private_access   = false
        endpoint_public_access    = true
        public_access_cidrs       = [
            "0.0.0.0/0",
        ]
        security_group_ids        = [
            "sg-0fd7d77abf67df98e",
        ]
        subnet_ids                = [
            "subnet-01e3cb63d5695a5bf",
            "subnet-02173240493284119",
            "subnet-04d56f5157ed685f3",
            "subnet-04e6709882e1433c4",
            "subnet-066d1a420c6af419d",
            "subnet-0c4854552324f79f8",
        ]
    }
}

resource "kubernetes_deployment" "deployment-oltur-terraform" {
  metadata {
    name = "oltur-terraform"
    labels = {
      app = "oltur-terraform"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "oltur-terraform"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          app = "oltur-terraform"
        }
      }

      spec {
        container {
          image = "916438688338.dkr.ecr.eu-west-1.amazonaws.com/oltur-terraform:latest"
          name  = "oltur-terraform"

          image_pull_policy = "Always"
          port {
            container_port = 80
            protocol = "TCP"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "livez"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}