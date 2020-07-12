# It may be useful to use a prebuilt server, so that no Android SDK is required
# to build. If the 'prebuilt_server' option is set, just copy the file as is.
prebuilt_server = get_option('prebuilt_server')
if prebuilt_server == ''
    custom_target('vcast-server',
                  # gradle is responsible for tracking source changes
                  build_by_default: true,
                  build_always_stale: true,
                  output: 'vcast-server',
                  command: [find_program('./scripts/build-wrapper.sh'), meson.current_source_dir(), '@OUTPUT@', get_option('buildtype')],
                  console: true,
                  install: true,
                  install_dir: 'share/vcast')
else
    if not prebuilt_server.startswith('/')
        # relative path needs some trick
        prebuilt_server = meson.source_root() + '/' + prebuilt_server
    endif
    custom_target('vcast-server-prebuilt',
                  input: prebuilt_server,
                  output: 'vcast-server',
                  command: ['cp', '@INPUT@', '@OUTPUT@'],
                  install: true,
                  install_dir: 'share/vcast')
endif
