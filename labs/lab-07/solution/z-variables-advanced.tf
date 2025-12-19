# Use a map when you need a variable that accepts an 
# arbitrary set of key-value pairs, but all the values 
# are of the same type.

variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "m5.large"
  }
}

# Use an object when you need a variable to represent 
# a well-defined data structure where you know all the 
# attribute names and their types in advance.

variable "server_config" {
  type = object({
    name      = string
    cpu_cores = number
    tags      = map(string)
    enabled   = bool
  })
}

# --- #

# Null: omits the value. Allows a provider to use the default
# behavior or ignore completely

# variables.tf

variable "app_id" {
  description = "Optional application ID. Set to null to omit this argument."
  type        = string
  default     = ""
}

# main.tf

resource "null_resource" "example" {
  # ... other arguments ...

  # If var.app_id is an empty string, set app_id argument to null (omitted).
  # Otherwise, use the provided app_id value.
  triggers = {
    app_id = var.app_id == "" ? null : var.app_id
  }
}

