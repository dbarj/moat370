#!/bin/bash
#************************************************************************
#
#   Copyright 2021  Rodrigo Jorge <http://www.dbarj.com.br/>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#************************************************************************

set -euo pipefail

if [ -z "${BASH_VERSION}" -o "${BASH}" = "/bin/sh" ]
then
  >&2 echo "Script must be executed in BASH shell."
  exit 1
fi

# Arguments
v_parameters=("$@") 

v_this_script="$(basename -- "$0")"
v_this_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
v_base_dir="$(cd -P "$v_this_dir/.."; pwd)"
# v_this_dir=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P) # Folder of this script

# Load all code functions.
source "${v_this_dir}"/moat370_functions_core.sh
source "${v_this_dir}"/moat370_functions_datatypes.sh
source "${v_this_dir}"/moat370_functions_procsql.sh
source "${v_this_dir}"/moat370_functions_csv_parser.sh
source "${v_this_dir}"/moat370_functions_charts.sh

trap 'trap_error $LINENO' ERR
trap 'exit_error "Code interrupted."' SIGINT SIGTERM

bin_check_exit awk
bin_check_exit mkfifo

source "${v_this_dir}"/moat370_0b_pre.sh

section_id='0a'
fc_db_define_module

fc_reset_defaults

if [ -f "${moat370_sw_folder}/sh/${moat370_sw_name}_0a_pre.sh" ]
then
  fc_echo_screen_log ""
  fc_echo_screen_log division
  fc_echo_screen_log ""
  fc_echo_screen_log "Running ${moat370_sw_name}_0a_pre.sh"
  source "${moat370_sw_folder}/sh/${moat370_sw_name}_0a_pre.sh"
fi

if [ -f "${moat370_sw_folder}/sql/${moat370_sw_name}_0a_pre.sql" ]
then
  fc_echo_screen_log ""
  fc_echo_screen_log division
  fc_echo_screen_log ""
  fc_echo_screen_log "Running ${moat370_sw_name}_0a_pre.sql"
  fc_db_run_file "${moat370_sw_folder}/sql/${moat370_sw_name}_0a_pre.sql"
fi

## Report # of columns
moat370_total_cols=${moat370_sw_rpt_cols}

echo '<!--BEGIN_SENSITIVE_DATA-->' >> "${moat370_main_report}"
echo '<table><tr class="main">' >> "${moat370_main_report}"

v_i=1
while [ ${v_i} -le ${moat370_total_cols} ]
do
  if [ ${v_i} -eq 1 ]
  then
    echo "<td class=\"c\">${v_i}/${moat370_total_cols}</td>" >> "${moat370_main_report}"
  else
    echo "<td class=\"c i${v_i}\">${v_i}/${moat370_total_cols}</td>" >> "${moat370_main_report}"
  fi
  let v_i=${v_i}+1
done

echo '</tr><tr class="main"><td>' >> "${moat370_main_report}"
echo "<img src=\"${moat370_sw_logo_file}\" alt=\"${moat370_sw_name}\" height=\"228\" width=\"auto\"" >> "${moat370_main_report}"
echo "title=\"${moat370_sw_logo_title_1}" >> "${moat370_main_report}"

[ -n "${moat370_sw_logo_title_2}" ] && echo "${moat370_sw_logo_title_2}" >> "${moat370_main_report}" 
[ -n "${moat370_sw_logo_title_3}" ] && echo "${moat370_sw_logo_title_3}" >> "${moat370_main_report}" 
[ -n "${moat370_sw_logo_title_4}" ] && echo "${moat370_sw_logo_title_4}" >> "${moat370_main_report}" 
[ -n "${moat370_sw_logo_title_5}" ] && echo "${moat370_sw_logo_title_5}" >> "${moat370_main_report}" 
[ -n "${moat370_sw_logo_title_6}" ] && echo "${moat370_sw_logo_title_6}" >> "${moat370_main_report}" 
[ -n "${moat370_sw_logo_title_7}" ] && echo "${moat370_sw_logo_title_7}" >> "${moat370_main_report}" 
[ -n "${moat370_sw_logo_title_8}" ] && echo "${moat370_sw_logo_title_8}" >> "${moat370_main_report}"

echo '">' >> "${moat370_main_report}"
echo '<br>' >> "${moat370_main_report}"

fc_def_output_file step_main_file_driver 'step_main_file_driver_columns.sql'

v_i=1
while [ ${v_i} -le ${moat370_total_cols} ]
do
  fc_load_column "${v_i}"
  if [ ${v_i} -lt ${moat370_total_cols} ]
  then
    echo "</td><td class=\"i`expr ${v_i} + 1`\">" >> "${moat370_main_report}"
  else
    echo '</td>' >> "${moat370_main_report}"
  fi
  let v_i=${v_i}+1
done

## main footer
echo '</tr></table>' >> "${moat370_main_report}"
echo '<!--END_SENSITIVE_DATA-->' >> "${moat370_main_report}"

fc_db_end_code

section_id='0c'
fc_db_define_module

## Load custom post if exists
if [ -f "${moat370_sw_folder}/sql/${moat370_sw_name}_0b_post.sql" ]
then
  fc_echo_screen_log ""
  fc_echo_screen_log division
  fc_echo_screen_log ""
  fc_echo_screen_log "Running ${moat370_sw_name}_0b_post.sql"
  fc_db_run_file "${moat370_sw_folder}/sql/${moat370_sw_name}_0b_post.sql"
fi

if [ -f "${moat370_sw_folder}/sh/${moat370_sw_name}_0b_post.sh" ]
then
  fc_echo_screen_log ""
  fc_echo_screen_log division
  fc_echo_screen_log ""
  fc_echo_screen_log "Running ${moat370_sw_name}_0b_post.sh"
  source "${moat370_sw_folder}/sh/${moat370_sw_name}_0b_post.sh"
fi

source "${v_this_dir}"/moat370_0c_post.sh

fc_encrypt_output "${moat370_zip_filename}.zip"

if [ -f "${moat370_zip_filename}.zip" ]
then
  # Not using fc_echo_screen_log as log file is already zipped
  echo ""
  echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  echo ""
  unzip -l "${moat370_zip_filename}"
fi

echo "End ${moat370_sw_name}. Output: ${moat370_zip_filename}.zip"

## END