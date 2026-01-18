#!/usr/bin/env bash
set -euo pipefail

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
values_file="${1:-"${base_dir}/values_template.yaml"}"
output_file="${2:-"${base_dir}/values.yaml"}"

# Update these values before running this script.
# Output goes to values.yaml unless you pass a second argument.
nersc_user_id="75369"
nersc_user_group="75369"
service_port="8080"
ingress_name="adminer" # <ingress_name>.<namespace>.<cluster>.svc.spin.nersc.org
domain="nova-adminer.x2d2.net"
domain_list="nova-adminer.x2d2.net:adminer.nova-ecl.production.svc.spin.nersc.org"
email="pding@lbl.gov"
cluster="production.svc.spin.nersc.org"
use_case="case2"
# case 1: use an existing web-server, specify the same port number used by the webserver's cluster IP.
# case 2: no existing web-server, create one;

webserver_existing="false"
if [ "${use_case}" = "case1" ]; then
  webserver_existing="true"
fi

tmp_file="$(mktemp)"
sed \
  -e "s|{{nersc_user_id}}|${nersc_user_id}|g" \
  -e "s|{{nersc_user_group}}|${nersc_user_group}|g" \
  -e "s|{{service_port}}|${service_port}|g" \
  -e "s|{{ingress_name}}|${ingress_name}|g" \
  -e "s|{{domain}}|${domain}|g" \
  -e "s|{{domain_list}}|${domain_list}|g" \
  -e "s|{{email}}|${email}|g" \
  -e "s|{{cluster}}|${cluster}|g" \
  -e "s|{{use_case}}|${use_case}|g" \
  -e "s|{{webserver_existing}}|${webserver_existing}|g" \
  "$values_file" > "$tmp_file"
mv "$tmp_file" "$output_file"
