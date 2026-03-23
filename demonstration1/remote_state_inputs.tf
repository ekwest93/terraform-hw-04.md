# Получаем пароли из remote state папки vms
data "terraform_remote_state" "vms" {
  backend = "local"
  config = {
    path = "../vms/terraform.tfstate"
  }
}

locals {
  vms_passwords = data.terraform_remote_state.vms.outputs.out
}
