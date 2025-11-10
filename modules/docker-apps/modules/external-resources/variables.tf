variable "remote_docker_host" {
  description = "IP/Hostname of the Docker instance to use"
  type        = string
}

variable "ssl_client_certificates" {
  description = "Path to the `ca.pem`, the `cert.pem` and the `key.pem` certificates."
  type        = string
}

variable "networks" {
  description = "Networks in Docker to create"
  type = map(object({
    subnet  = string
    gateway = string
    driver  = optional(string)
    labels  = optional(map(string), {})
  }))
  default = {}
}

variable "volumes" {
  description = "Volumes in Docker to create (to be used as `external` volumes)"
  type = map(object({
    labels      = optional(map(string), {})
    driver      = optional(string)
    driver_opts = optional(map(string), null)
  }))
  default = {}
}