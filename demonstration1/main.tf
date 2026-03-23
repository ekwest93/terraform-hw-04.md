# Создаём облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

# Создаём подсеть
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Группа безопасности
resource "yandex_vpc_security_group" "main" {
  name       = "main-sg"
  network_id = yandex_vpc_network.develop.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Шаблон cloud-init
data "template_file" "cloudinit" {
  template = file("../vms/cloud-init.yml")
  vars = {
    ssh_public_key = file("~/.ssh/id_rsa.pub")
  }
}

# VM для маркетинга
module "marketing_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name       = "marketing"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [yandex_vpc_subnet.develop_a.id]
  instance_name  = "marketing"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "marketing"
    env     = "prod"
  }

  metadata = {
    user-data = data.template_file.cloudinit.rendered
  }
}

# VM для аналитики
module "analytics_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name       = "analytics"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [yandex_vpc_subnet.develop_a.id]
  instance_name  = "analytics"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "analytics"
    env     = "prod"
  }

  metadata = {
    user-data = data.template_file.cloudinit.rendered
  }
}


# Вывод информации о ВМ
output "marketing_vm_external_ip" {
  description = "External IP of marketing VM"
  value       = module.marketing_vm.external_ip_address
}

output "analytics_vm_external_ip" {
  description = "External IP of analytics VM"
  value       = module.analytics_vm.external_ip_address
}

output "marketing_vm_fqdn" {
  description = "FQDN of marketing VM"
  value       = module.marketing_vm.fqdn
}

output "analytics_vm_fqdn" {
  description = "FQDN of analytics VM"
  value       = module.analytics_vm.fqdn
}
