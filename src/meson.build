gnome = import('gnome')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gcr-4'),
    dependency('gtk4'),
    dependency('gtk4-layer-shell-0'),
    dependency('libadwaita-1')
]

sources = [
  'prompt.vala',
  'window.vala',
  'background.vala',
  'main.vala'
]

blueprints = custom_target('blueprints',
  input: files(
    'ui/window.blp'
  ),
  output: 'ui',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', 'ui', '@INPUT@'],
)

sources += gnome.compile_resources(
    'gprompt',
    'gprompt.gresource.xml',
    c_name: 'gprompt',
    dependencies: blueprints
)

executable('gprompt', sources, dependencies : dependencies,
  install : true, c_args: ['-DGCR_API_SUBJECT_TO_CHANGE',])