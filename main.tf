#recurso para instancia oci compute
resource "oci_core_instance" "ubuntu-vm" {
    compartment_id      = var.compartment_ocid
    display_name        = "ubuntu-web-nginx"
    availability_domain = var.availability_domain
    shape               = "VM.Standard.E2.1"

    #configuracion de red
    create_vnic_details {
        subnet_id = var.subnet_ocid
        assign_public_ip = true
        display_name = "vnic-unbuntu-web"
        hostname_label = "ubuntu-web-vm"
    }

    # configuracion de la imagen
    source_details {
        source_type = "image"
        source_id    = var.ubuntu_2404_image_ocid
    }

    #Metadatos: clave SSH y script de inicializacion externo
    metadata = {
      ssh_authorized_keys = var.ssh_public_key
      user_data = base64encode(file("${path.module}/scripts/setup_nginx_web.sh"))
    }
}

output "public_ip" {
    value = oci_core_instance.ubuntu-vm.public_ip
    description = "IP publica de servidor web"
}
