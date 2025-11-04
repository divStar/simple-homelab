resource "local_file" "ignition_file" {
  filename = "${path.module}/output/config.ign"
  content  = data.ct_config.flatcar.rendered
}

resource "local_file" "butane_file" {
  filename = "${path.module}/output/config.yaml"
  content  = data.ct_config.flatcar.content
}