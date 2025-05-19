gnome = import('gnome')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gcr-4'),
    dependency('gtk4'),
    dependency('libadwaita-1')
]

sources = [
  'prompt.vala',
  'window.vala',
  'main.vala'
]

subdir('ui')

sources += gnome.compile_resources(
    'gprompt',
    'gprompt.gresource.xml',
    c_name: 'gprompt',
    dependencies: blueprints
)

executable('gprompt', sources, dependencies : dependencies,
  install : true)