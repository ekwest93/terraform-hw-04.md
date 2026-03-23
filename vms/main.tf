# Генерируем случайные пароли для ВМ
resource "random_password" "input_vms" {
  for_each = toset(var.vms_list)
  length   = 16
  special  = true
}

# Выводим пароли (для использования в demonstration1)
output "out" {
  value = { for k, v in random_password.input_vms : k => nonsensitive(v.result) }
}
