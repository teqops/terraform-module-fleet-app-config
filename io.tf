variable "branch" {
  default = "master"
}

variable "repo" {
}

variable "name" {
}

variable "extra_paths" {
  default = []
}

variable "root" {
  default = false
}

variable "private" {
  default = false
}

variable "existing" {
  default = false
}

variable "ssh" {
  default = false
}

variable "ssh_key" {
  default = ""
}

variable "secret" {
  default = ""
}

variable "git_password" {
  default = ""
}

variable "git_username" {
  default = ""
}