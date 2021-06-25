{% from "./defaults/map.jinja" import git_data with context -%}
{% from "./defaults/ssh.jinja" import ssh_data with context -%}

{% if 'git_hosts' in ssh_data -%}
{%- for git_host, git_key in ssh_data['git_hosts']|dictsort %}

{%- set git_line_regex = "^\s*" + git_host + "\s+\S+\s+\S+\s*$" -%}
{{ git_data['user_name'] }}-known_hosts-{{ git_host }}:
  file.line:
    - name: {{ git_data['user_home'] }}/.ssh/known_hosts
    - content: "{{ git_host }} {{ git_key }}"
    - match: '{{ git_line_regex }}'
    - mode: insert
    - location: end
    - create: True
    - user: git_data['user_name']
    - group: git_data['user_group']
    - file_mode: 644
    - unless:
        grep -Pxq "{{ git_line_regex }}" {{ git_data['user_home'] }}/.ssh/known_hosts

{%- endfor %}
{%- endif %}

{% if 'client_keys' in ssh_data -%}
{%- for key_file, key_value in ssh_data['client_keys']|dictsort %}
{{ git_data['user_home'] }}/.ssh/{{ key_file }}:
  file.managed:
    - contents: |
        {{ key_value | indent(8) }}
    - user: git_data['user_name']
    - group: git_data['user_group']
    - mode: 600  
{%- endfor %}
{%- endif %}

{%- endif %}

