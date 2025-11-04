resource "local_file" "ignition_file" {
  filename = "${path.module}/output/config.ign"
  content  = data.ct_config.flatcar.rendered
}
