#!/bin/bash
#************************************************************************
#
#   Copyright 2021  Rodrigo Jorge <http://www.dbarj.com.br/>
#
#   Licensed under the Apache License, Version 2.0 (the "License"
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES -o CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#************************************************************************

## Check for mandatory variables and put their default values if unset or stop the code.

## moat370_sw_output_fdr must be the first as it is used in fc_validate_variable -> step_file
declare moat370_pre_sw_output_fdr
fc_set_value_var_nvl 'moat370_sw_output_fdr' "${moat370_pre_sw_output_fdr}" '.'
fc_exit_no_folder_perms

## DEBUG must be the second as it is used in fc_validate_variable -> fc_set_term_off
declare DEBUG
fc_set_value_var_nvl 'DEBUG'  "${DEBUG}"  'OFF'

fc_validate_variable DEBUG ON_OFF

## Some software parameters are mandatory:

declare moat370_sw_name
declare moat370_sw_logo_file
declare moat370_sw_icon_file
declare moat370_sw_cert_file
declare moat370_sw_title_desc
declare moat370_sw_url
declare moat370_sw_rpt_cols
declare moat370_sw_misc_fdr
declare moat370_sw_logo_title_1
declare moat370_sw_logo_title_2
declare moat370_sw_logo_title_3
declare moat370_sw_logo_title_4
declare moat370_sw_logo_title_5
declare moat370_sw_logo_title_6
declare moat370_sw_logo_title_7
declare moat370_sw_logo_title_8
declare moat370_sw_vYYNN
declare moat370_sw_vrsn
declare moat370_sw_copyright
declare moat370_sw_author
declare moat370_sw_email
declare moat370_sw_dbtool
declare moat370_sw_enc_sql
declare moat370_sw_gchart_path
declare moat370_sw_db_type

fc_set_value_var_nvl 'moat370_sw_misc_fdr'   "${moat370_sw_misc_fdr}" 'js'
fc_set_value_var_nvl 'moat370_sw_rpt_cols'   "${moat370_sw_rpt_cols}" '7'

fc_validate_variable moat370_sw_name       NOT_NULL
fc_validate_variable moat370_sw_name       LOWER_CASE
fc_validate_variable moat370_sw_title_desc NOT_NULL
fc_validate_variable moat370_sw_vYYNN      NOT_NULL
fc_validate_variable moat370_sw_vrsn       NOT_NULL
fc_validate_variable moat370_sw_rpt_cols   IS_NUMBER

fc_set_value_var_nvl 'moat370_sw_copyright' "${moat370_sw_copyright}" "${moat370_sw_name} (c) ${moat370_fw_vYYYY}, All rights reserved."
fc_set_value_var_nvl 'moat370_sw_email'     "${moat370_sw_email}"     'unknown@example.com'

fc_validate_variable moat370_sw_email      LOWER_CASE
fc_validate_variable moat370_sw_author     NOT_NULL

## moat370_sw_dbtool declares if the API is being used primarily for a database or is just a interface to other calls.
fc_set_value_var_nvl 'moat370_sw_dbtool'  "${moat370_sw_dbtool}"    'Y'
fc_validate_variable moat370_sw_dbtool    Y_N

fc_set_value_var_nvl 'moat370_sw_enc_sql'  "${moat370_sw_enc_sql}"  'N'
fc_validate_variable moat370_sw_enc_sql    Y_N

fc_set_value_var_nvl 'moat370_sw_gchart_path'  "${moat370_sw_gchart_path}"  'https://www.gstatic.com/charts/loader.js'

##-------------------------

declare moat370_sw_param1
declare moat370_sw_param2
declare moat370_sw_param3
declare moat370_sw_param4
declare moat370_sw_param5

declare moat370_sw_param1_var
declare moat370_sw_param2_var
declare moat370_sw_param3_var
declare moat370_sw_param4_var
declare moat370_sw_param5_var

fc_set_value_var_nvl 'moat370_sw_param1' "${moat370_sw_param1}" 'section'
fc_set_value_var_nvl 'moat370_sw_param2' "${moat370_sw_param2}" 'null'
fc_set_value_var_nvl 'moat370_sw_param3' "${moat370_sw_param3}" 'null'
fc_set_value_var_nvl 'moat370_sw_param4' "${moat370_sw_param4}" 'null'
fc_set_value_var_nvl 'moat370_sw_param5' "${moat370_sw_param5}" 'null'

fc_validate_variable moat370_sw_param1 RANGE 'license,section,custom,null'
fc_validate_variable moat370_sw_param2 RANGE 'license,section,custom,null'
fc_validate_variable moat370_sw_param3 RANGE 'license,section,custom,null'
fc_validate_variable moat370_sw_param4 RANGE 'license,section,custom,null'
fc_validate_variable moat370_sw_param5 RANGE 'license,section,custom,null'

##-------------------------

declare moat370_pre_encrypt_output
declare moat370_pre_encrypt_html
declare moat370_pre_compress_html

declare moat370_conf_encrypt_output
declare moat370_conf_encrypt_html
declare moat370_conf_compress_html

fc_set_value_var_nvl 'moat370_conf_encrypt_output' "${moat370_pre_encrypt_output}" "${moat370_conf_encrypt_output}"
fc_set_value_var_nvl 'moat370_conf_encrypt_html'   "${moat370_pre_encrypt_html}"   "${moat370_conf_encrypt_html}"  
fc_set_value_var_nvl 'moat370_conf_compress_html'  "${moat370_pre_compress_html}"  "${moat370_conf_compress_html}"  

fc_set_value_var_nvl 'moat370_conf_encrypt_output' "${moat370_conf_encrypt_output}" 'OFF'
fc_set_value_var_nvl 'moat370_conf_encrypt_html'   "${moat370_conf_encrypt_html}"   'OFF'
fc_set_value_var_nvl 'moat370_conf_compress_html'  "${moat370_conf_compress_html}"  'OFF'

fc_validate_variable moat370_conf_encrypt_output ON_OFF
fc_validate_variable moat370_conf_encrypt_html   ON_OFF
fc_validate_variable moat370_conf_compress_html  ON_OFF

##-------------------------

declare moat370_conf_incl_html
declare moat370_conf_incl_text
declare moat370_conf_incl_csv
declare moat370_conf_incl_line
declare moat370_conf_incl_pie
declare moat370_conf_incl_bar
declare moat370_conf_incl_graph
declare moat370_conf_incl_map
declare moat370_conf_incl_treemap
declare moat370_conf_incl_file

fc_set_value_var_nvl 'moat370_conf_incl_html'    "${moat370_conf_incl_html}"    'Y'
fc_set_value_var_nvl 'moat370_conf_incl_text'    "${moat370_conf_incl_text}"    'N'
fc_set_value_var_nvl 'moat370_conf_incl_csv'     "${moat370_conf_incl_csv}"     'N'
fc_set_value_var_nvl 'moat370_conf_incl_line'    "${moat370_conf_incl_line}"    'Y'
fc_set_value_var_nvl 'moat370_conf_incl_pie'     "${moat370_conf_incl_pie}"     'Y'
fc_set_value_var_nvl 'moat370_conf_incl_bar'     "${moat370_conf_incl_bar}"     'Y'
fc_set_value_var_nvl 'moat370_conf_incl_graph'   "${moat370_conf_incl_graph}"   'Y'
fc_set_value_var_nvl 'moat370_conf_incl_map'     "${moat370_conf_incl_map}"     'Y'
fc_set_value_var_nvl 'moat370_conf_incl_treemap' "${moat370_conf_incl_treemap}" 'Y'
fc_set_value_var_nvl 'moat370_conf_incl_file'    "${moat370_conf_incl_file}"    'Y'

fc_validate_variable moat370_conf_incl_html    Y_N
fc_validate_variable moat370_conf_incl_text    Y_N
fc_validate_variable moat370_conf_incl_csv     Y_N
fc_validate_variable moat370_conf_incl_line    Y_N
fc_validate_variable moat370_conf_incl_pie     Y_N
fc_validate_variable moat370_conf_incl_bar     Y_N
fc_validate_variable moat370_conf_incl_graph   Y_N
fc_validate_variable moat370_conf_incl_map     Y_N
fc_validate_variable moat370_conf_incl_treemap Y_N
fc_validate_variable moat370_conf_incl_file    Y_N

##-------------------------

declare moat370_conf_def_html
declare moat370_conf_def_text
declare moat370_conf_def_csv
declare moat370_conf_def_line
declare moat370_conf_def_pie
declare moat370_conf_def_bar
declare moat370_conf_def_graph
declare moat370_conf_def_map
declare moat370_conf_def_treemap
declare moat370_conf_def_file

fc_set_value_var_nvl 'moat370_conf_def_html'    "${moat370_conf_def_html}"    'Y'
fc_set_value_var_nvl 'moat370_conf_def_text'    "${moat370_conf_def_text}"    'N'
fc_set_value_var_nvl 'moat370_conf_def_csv'     "${moat370_conf_def_csv}"     'N'
fc_set_value_var_nvl 'moat370_conf_def_line'    "${moat370_conf_def_line}"    'N'
fc_set_value_var_nvl 'moat370_conf_def_pie'     "${moat370_conf_def_pie}"     'N'
fc_set_value_var_nvl 'moat370_conf_def_bar'     "${moat370_conf_def_bar}"     'N'
fc_set_value_var_nvl 'moat370_conf_def_graph'   "${moat370_conf_def_graph}"   'N'
fc_set_value_var_nvl 'moat370_conf_def_map'     "${moat370_conf_def_map}"     'N'
fc_set_value_var_nvl 'moat370_conf_def_treemap' "${moat370_conf_def_treemap}" 'N'
fc_set_value_var_nvl 'moat370_conf_def_file'    "${moat370_conf_def_file}"    'N'

fc_validate_variable moat370_conf_def_html    Y_N
fc_validate_variable moat370_conf_def_text    Y_N
fc_validate_variable moat370_conf_def_csv     Y_N
fc_validate_variable moat370_conf_def_line    Y_N
fc_validate_variable moat370_conf_def_pie     Y_N
fc_validate_variable moat370_conf_def_bar     Y_N
fc_validate_variable moat370_conf_def_graph   Y_N
fc_validate_variable moat370_conf_def_map     Y_N
fc_validate_variable moat370_conf_def_treemap Y_N
fc_validate_variable moat370_conf_def_file    Y_N

##-------------------------

declare moat370_conf_incl_trace
declare moat370_conf_incl_opatch
declare moat370_conf_ask_license
declare moat370_conf_sql_format
declare moat370_conf_sql_highlight
declare moat370_conf_tablefilter

fc_set_value_var_nvl 'moat370_conf_incl_trace'    "${moat370_conf_incl_trace}"   'N'
fc_set_value_var_nvl 'moat370_conf_incl_opatch'   "${moat370_conf_incl_opatch}"   'N'
fc_set_value_var_nvl 'moat370_conf_ask_license'   "${moat370_conf_ask_license}"   'N'
fc_set_value_var_nvl 'moat370_conf_sql_format'    "${moat370_conf_sql_format}"    'N'
fc_set_value_var_nvl 'moat370_conf_sql_highlight' "${moat370_conf_sql_highlight}" 'Y'
fc_set_value_var_nvl 'moat370_conf_tablefilter'   "${moat370_conf_tablefilter}"   'Y'

fc_validate_variable moat370_conf_incl_trace    Y_N
fc_validate_variable moat370_conf_incl_opatch   Y_N
fc_validate_variable moat370_conf_ask_license   Y_N
fc_validate_variable moat370_conf_sql_format    Y_N
fc_validate_variable moat370_conf_sql_highlight Y_N
fc_validate_variable moat370_conf_tablefilter   Y_N

##-------------------------

declare moat370_def_sql_format
declare moat370_def_sql_highlight
declare moat370_def_sql_maxrows
declare moat370_def_sql_show

fc_set_value_var_nvl 'moat370_def_sql_format'    "${moat370_def_sql_format}"    'Y'
fc_set_value_var_nvl 'moat370_def_sql_highlight' "${moat370_def_sql_highlight}" 'Y'
fc_set_value_var_nvl 'moat370_def_sql_maxrows'   "${moat370_def_sql_maxrows}"   '10000'
fc_set_value_var_nvl 'moat370_def_sql_show'      "${moat370_def_sql_show}"      'Y'

fc_validate_variable moat370_def_sql_format    Y_N
fc_validate_variable moat370_def_sql_highlight Y_N
fc_validate_variable moat370_def_sql_maxrows   IS_NUMBER
fc_validate_variable moat370_def_sql_show      Y_N

##-------------------------

declare moat370_sections

##-------------------------

declare moat370_conf_days
declare moat370_conf_date_from
declare moat370_conf_date_to
declare moat370_conf_work_time_from
declare moat370_conf_work_time_to
declare moat370_conf_work_day_from
declare moat370_conf_work_day_to

fc_set_value_var_nvl 'moat370_conf_days'           "${moat370_conf_days}"           '31'
fc_set_value_var_nvl 'moat370_conf_date_from'      "${moat370_conf_date_from}"      'YYYY-MM-DD'
fc_set_value_var_nvl 'moat370_conf_date_to'        "${moat370_conf_date_to}"        'YYYY-MM-DD'
fc_set_value_var_nvl 'moat370_conf_work_time_from' "${moat370_conf_work_time_from}" '0730'
fc_set_value_var_nvl 'moat370_conf_work_time_to'   "${moat370_conf_work_time_to}"   '1930'
fc_set_value_var_nvl 'moat370_conf_work_day_from'  "${moat370_conf_work_day_from}"  '2'
fc_set_value_var_nvl 'moat370_conf_work_day_to'    "${moat370_conf_work_day_to}"    '6'

fc_validate_variable moat370_conf_days           IS_NUMBER
fc_validate_variable moat370_conf_work_time_from IS_NUMBER
fc_validate_variable moat370_conf_work_time_to   IS_NUMBER
fc_validate_variable moat370_conf_work_day_from  IS_NUMBER
fc_validate_variable moat370_conf_work_day_to    IS_NUMBER

##-------------------------

declare moat370_sw_desc_linesize
fc_set_value_var_nvl 'moat370_sw_desc_linesize'  "${moat370_sw_desc_linesize}"  '80'
fc_validate_variable  moat370_sw_desc_linesize   IS_NUMBER
