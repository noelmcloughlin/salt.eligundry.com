{% set letsencrypt_dir = '/opt/letsencrypt' %}
{% set pull_latest = pillar['docker_pull_latest'] %}
{% set nginx_image = 'jwilder/nginx-proxy:alpine' %}
{% set letsencrypt = pillar['letsencrypt'] %}
{% set letsencrypt_image = 'jrcs/letsencrypt-nginx-proxy-companion:latest' %}

https-portal-stopped:
  docker_container.absent:
    - names:
      - https-portal
    - force: True

{{ letsencrypt_dir }}:
  file.directory:
    - user: docker
    - group: docker
    - dir_mode: 775
    - file_mode: 660
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

{{ nginx_image }}:
  docker_image.present:
    - force: {{ pull_latest }}

nginx-proxy:
  docker_container.running:
    - image: {{ nginx_image }}
    - volumes:
      - /etc/nginx/conf.d
      - /etc/nginx/vhost.d
      - /usr/share/nginx/html
    - binds:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - {{ letsencrypt_dir }}:/etc/nginx/certs:ro
    - port_bindings:
      - "80:80"
      - "443:443"
    - restart_policy: always
    - require:
      - {{ nginx_image }}
      - {{ letsencrypt_dir }}

# This is disabled in Vagrant because it will fail to validate certs and make
# the dev website impossible to reach because certs and will force SSL on the
# Nginx reverse proxy.
{% if salt['grains.get']('virtual') != 'VirtualBox' %}

{{ letsencrypt_image }}:
  docker_image.present:
    - force: {{ pull_latest }}

letsencrypt:
  docker_container.running:
    - image: {{ letsencrypt_image }}
    - volumes_from:
      - nginx-proxy
    - binds:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - {{ letsencrypt_dir }}:/etc/nginx/certs:rw
    - restart_policy: always
    - environment:
      - ACME_TOS_HASH=cc88d8d9517f490191401e7b54e9ffd12a2b9082ec7a1d4cec6101f9f1647e7b
    - require:
      - {{ letsencrypt_dir }}
      - {{ letsencrypt_image }}
      - nginx-proxy

{% endif %}
