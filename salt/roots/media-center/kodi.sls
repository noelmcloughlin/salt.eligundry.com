{% set os = grains['os'] %}
{% set codename = grains['lsb_distrib_codename'] %}

{% if os == 'Debian' %}
  {% set codename = pillar['debian_ppa_codename'] %}
{% endif %}

{% if os != 'Debian' %}
kodi-ppa:
  pkgrepo.managed:
    - humanname: Kodi Media Center
    - name: deb http://ppa.launchpad.net/team-xbmc/ppa/ubuntu zesty main
    - keyid: 91E7EE5E
    - keyserver: keyserver.ubuntu.com
    - file: /etc/apt/sources.list.d/kodi.list
{% endif %}

kodi:
  pkg.installed:
    - pkgs:
      - kodi
      - kodi-addons-dev
