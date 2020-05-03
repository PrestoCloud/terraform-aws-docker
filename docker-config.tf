# resource "docker_config" "efs_config" {
#   name = "${var.service_name}-config-${replace(timestamp(),":", ".")}"
#   data = "${base64encode(data.template_file.service_config_tpl.rendered)}"

#   lifecycle {
#     ignore_changes        = ["name"]
#     create_before_destroy = true
#   }
# }

# resource "docker_service" "service" {
#   # ...
#   configs = [
#     {
#       config_id   = "${docker_config.service_config.id}"
#       config_name = "${docker_config.service_config.name}"
#       file_name   = "/root/configs/configs.json"
#     },
#   ]
# }