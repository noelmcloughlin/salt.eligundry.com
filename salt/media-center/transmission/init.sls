transmission-daemon:
  pkg.installed

/var/lib/transmission/settings.json:
  file.managed:
    - source: salt://media-center/transmission/settings.json
    - user: debian-transmission
    - group: debian-transmission
    - mode: 600
    - template: jinja
    - require:
      - pkg: transmission-daemon

transmission-daemon-service:
  service.running:
    - name: transmission-daemon
    - enable: True
    - watch:
      - file: /var/lib/transmission/settings.json
    - require:
      - pkg: transmission-daemon
