output "cv_challenge_public_ip" {
  value = aws_instance.cv_challenge.public_ip
}

output "access_urls" {
  value = {
    main_app   = "https://${var.domain_name}"
    adminer    = "https://db.${var.domain_name}"
    cadvisor   = "https://${var.domain_name}/cadvisor"
    prometheus = "https://${var.domain_name}/prometheus"
    grafana    = "https://${var.domain_name}/grafana"
  }
}

output "ansible_inventory_path" {
  value = abspath("${path.module}/ansible/inventory.ini")
}