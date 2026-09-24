systemd_dep = dependency('systemd')
systemd_unit_dir = systemd_dep.get_variable(pkgconfig: 'systemduserunitdir')

bin_path = get_option('prefix') / get_option('bindir') / 'gprompt'

config = configuration_data()
config.set('BIN_PATH', bin_path)

service_name = 'gprompt.service'

configure_file(
  input: service_name + '.in',
  output: service_name,
  configuration: config,
  install: true,
  install_dir: systemd_unit_dir
)
