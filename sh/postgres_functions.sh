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

########################
# Mandatory Functions: #
########################

# fc_db_startup_connection
# fc_db_end_connection
# fc_db_check_connection
# fc_db_begin_code
# fc_db_end_code
# fc_db_run_file
# fc_db_define_module
# fc_db_reset_options
# fc_db_pre_section_call
# fc_db_create_csv
# fc_db_create_raw
# fc_db_table_description
# fc_db_check_file_sql_error
# fc_db_enable_trace
# fc_db_pre_exec_call
# fc_db_sql_transform

# printf %s\\n "$-"
bin_check_exit psql
bin_check_exit mkfifo

fc_db_startup_connection ()
{
  fc_def_output_file v_database_fifo_file 'database.fifo.sql'
  [ -f "${v_database_fifo_file}" -o -p "${v_database_fifo_file}" ] && rm -f "${v_database_fifo_file}"
  mkfifo "${v_database_fifo_file}"
  exec 3<>"${v_database_fifo_file}"
  fc_def_output_file v_database_out_file 'database_output.log'
  fc_def_output_file v_database_err_file 'database_error.log'
  cat <&3 | psql --file - ${moat370_sw_db_conn_params} > "${v_database_out_file}" 2> "${v_database_out_file}" &
  v_db_client_pid=$!
}

fc_db_end_connection ()
{
  fc_run_query "EXIT;"
  [ -p "${v_database_fifo_file}" ] && rm -f "${v_database_fifo_file}"
  fc_seq_output_file v_database_out_file
  fc_zip_file "${moat370_zip_filename}" "${v_database_out_file}"
  kill_db_connection
}

fc_db_check_connection ()
{
  local v_loop_limit v_sleep_time v_total_sleep
  v_loop_limit=15
  v_sleep_time=1
  v_total_sleep=0

  fc_run_query '\pset tuples_only on'
  fc_run_query "SELECT CONCAT('I_AM_CONNECTED_',COUNT(*));"
  fc_run_query '\pset tuples_only off'

  set +x

  while :
  do
    if grep -q 'I_AM_CONNECTED_1' "${v_database_out_file}"
    then
      break
    fi
    sleep ${v_sleep_time}
    v_total_sleep=$(do_calc "v_total_sleep+1")
    if [ ${v_total_sleep} -gt ${v_loop_limit} ]
    then
      cat "${v_database_out_file}"
      exit_error "Unable to connect on database.. time limit exceeded."
    fi
  done

  fc_enable_set_x

}

fc_db_begin_code ()
{
  fc_db_run_file "${moat370_fdr}"/database/postgres/postgres_pre.sql
  fc_load_variable hosts_count
  fc_load_variable avg_core_count
  fc_load_variable avg_thread_count
  fc_load_variable database_name
  fc_load_variable host_name
  fc_load_variable db_version
}

fc_db_end_code ()
{
  fc_db_run_file "${moat370_fdr}"/database/postgres/postgres_post.sql
}

fc_db_run_file ()
{
  fc_run_query "\include $1"
  fc_check_executed
}

fc_db_define_module ()
{
  true
}

fc_db_reset_options ()
{
  fc_db_run_file "${moat370_fdr}"/database/postgres/postgres_reset.sql
}

fc_db_pre_section_call ()
{
  true
}

fc_db_create_csv ()
{
  local v_in_file="$1"
  local v_out_csv="$2"

  fc_def_output_file v_out_html 'fc_db_create_csv.out'
  rm -f "${v_out_html}"

  fc_def_output_file v_in_tmp 'fc_db_create_csv.tmp'
  cp "${moat370_fdr}/database/postgres/postgres_run_html.sql" "${v_in_tmp}"

  fc_replace_file_variable "${v_in_tmp}" '%%file_name%%' "${v_out_html}"
  fc_replace_file_variable "${v_in_tmp}" '%%error_file%%' "${v_database_err_file}"
  fc_replace_file_variable "${v_in_tmp}" '%%query_file%%' "${v_in_file}"
  rm -f "${v_database_err_file}"
  fc_run_query "\include ${v_in_tmp}"
  fc_check_executed
  rm -f "${v_in_tmp}"
  unset v_in_tmp

  fc_convert_html_to_csv "${v_out_html}" "${v_out_csv}"
  rm -f "${v_out_html}"
  unset v_out_html

  # This is not required as html characters are already converted.
  # fc_escape_markup_characters "${v_out_csv}" > "${v_out_csv}".tmp
  # mv "${v_out_csv}".tmp "${v_out_csv}"

  $cmd_sed -e ':a' -e '/./,$!d;/^\n*$/{$d;N;};/\n$/ba' "${v_out_csv}" > "${v_out_csv}".tmp
  mv "${v_out_csv}".tmp "${v_out_csv}"

  #fc_load_variable MOAT370_PREV_SQL_ID moat370_prev_sql_id
  #fc_load_variable MOAT370_PREV_CHILD_NUMBER moat370_prev_child_number

  fc_db_reset_options
}

fc_db_create_raw ()
{
  local v_in_file="$1"
  local v_out_raw="$2"

  fc_def_output_file v_in_tmp 'fc_db_create_csv.tmp'
  cp "${moat370_fdr}/database/postgres/postgres_run_raw.sql" "${v_in_tmp}"

  fc_replace_file_variable "${v_in_tmp}" '%%file_name%%' "${v_out_raw}"
  fc_replace_file_variable "${v_in_tmp}" '%%error_file%%' "${v_database_err_file}"
  fc_replace_file_variable "${v_in_tmp}" '%%query_file%%' "${v_in_file}"
  rm -f "${v_database_err_file}"
  fc_run_query "\include ${v_in_tmp}"
  fc_check_executed
  rm -f "${v_in_tmp}"
  unset v_in_tmp

  fc_db_reset_options
}

fc_db_table_description ()
{
  local v_output_file
  v_output_file="$1"

  fc_def_output_file v_in_tmp 'fc_db_table_description.tmp'
  cp "${moat370_fdr}/database/postgres/postgres_table_desc.sql" "${v_in_tmp}"

  fc_replace_file_variable "${v_in_tmp}" '%%file_name%%' "${v_output_file}.desc"
  fc_replace_file_variable "${v_in_tmp}" '%%table_name%%' "${main_table}"
  fc_run_query "\include ${v_in_tmp}"
  fc_check_executed
  rm -f "${v_in_tmp}"
  unset v_in_tmp

  # Remove desc file.
  cat "${v_output_file}.desc" >> "${v_output_file}"
  rm -f "${v_output_file}.desc"
}

fc_db_check_file_sql_error ()
{
  ## This code will check if file has an error.
  local v_in_file="${v_database_err_file}"
  local v_in_file_contents=$(cat "${v_in_file}")
  if [ "${v_in_file_contents}" = "true" ]
  then
    rm -f "${v_database_err_file}"
    return 1
  else
    rm -f "${v_database_err_file}"
    return 0
  fi
}

fc_db_enable_trace ()
{
  true
  # fc_run_query "ALTER SESSION SET MAX_DUMP_FILE_SIZE='1G';"
  # fc_run_query "ALTER SESSION SET TRACEFILE_IDENTIFIER=\"${moat370_tracefile_identifier}\";"
  # fc_run_query "ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL ${sql_trace_level}';"
}

fc_db_pre_exec_call ()
{
  true
}

fc_db_sql_transform ()
{
  local v_in_query="$1"
  printf 'SELECT row_number() OVER () AS ROW_NUM, v0.* FROM /* %s */ (\n%s\n) v0\nLIMIT %s;' "${section_id}.${report_sequence}" "${v_in_query}" "${max_rows}"
}

################################
###### INTERNAL FUNCTIONS ######
################################

fc_run_query ()
{
  echo "${1}" > "${v_database_fifo_file}"
}

fc_check_executed ()
{
  # Check if database FIFO file reached the end.
  fc_def_output_file v_fc_db_run_file_output 'run_file.out'
  rm -f "${v_fc_db_run_file_output}"

  fc_run_query "\out ${v_fc_db_run_file_output}"
  fc_run_query "\qecho FINISHED"
  fc_run_query "\out"
  fc_wait_string "${v_fc_db_run_file_output}" FINISHED

  rm -f "${v_fc_db_run_file_output}"
}

fc_load_variable ()
{
  # This code will convert USER DEFINED variables into SHELL variables.
  local v_load_variable_file v_load_variable_name v_output v_load_variable_result
  v_load_variable_name="$1"

  set +u
  v_load_target_name="$2"
  fc_enable_set_u

  fc_def_output_file v_temp_variable_file 'fc_load_variable.tmp'

  fc_def_output_file v_load_variable_file 'fc_load_variable.out'
  rm -f "${v_load_variable_file}"

  if [ "${v_load_variable_name}" != 'ALL' ]
  then
    cp "${moat370_fdr}/database/postgres/postgres_load_variable.sql" "${v_temp_variable_file}"
    fc_replace_file_variable "${v_temp_variable_file}" '%%var_name%%' "${v_load_variable_name}"
    fc_replace_file_variable "${v_temp_variable_file}" '%%file_name%%' "${v_load_variable_file}"
    fc_run_query "\include ${v_temp_variable_file}"
    fc_check_executed

    v_load_variable_result=$(cat "${v_load_variable_file}")

    if [ "${v_load_variable_result}" = ":${v_load_variable_name}" ]
    then
      echo_error "Undefined variable ${v_load_variable_name}."
      return
    fi

    eval ${v_load_variable_name}=\${v_load_variable_result}

  # TODO
  # else
  #   cp "${moat370_fdr}/database/postgres/postgres_load_variable_all.sql" "${v_temp_variable_file}"
  #   fc_replace_file_variable "${v_temp_variable_file}" '%%file_name%%' "${v_load_variable_file}"
  #   fc_run_query "\include ${v_temp_variable_file}"
  #   fc_check_executed
  fi

  # source "${v_load_variable_file}"
  rm -f "${v_temp_variable_file}"
  rm -f "${v_load_variable_file}"

}

fc_convert_html_to_csv ()
{
  # https://www.computerhope.com/unix/used.htm
  # https://unix.stackexchange.com/questions/335497/get-text-between-start-pattern-and-end-pattern-based-on-pattern-between-start-an
  # https://unix.stackexchange.com/questions/26284/how-can-i-use-sed-to-replace-a-multi-line-string
  # https://stackoverflow.com/questions/6588113/remove-new-line-if-next-line-does-not-begin-with-a-number/6616184
  # https://www.unix.com/shell-programming-and-scripting/267032-sed-remove-newline-chars-based-pattern-mis-match.html

  local v_in_file="$1"
  local v_out_file="$2"

  # Spool file
  cat "${v_in_file}" | \
  # Remove <br />. 
  $cmd_sed 's:<br />: :g' | \
  # Trim line, replace double the double quotes and remove empty lines. 
  $cmd_sed 's/^[[:space:]]*//g; s/[[:space:]]*$//g; s/&nbsp;//; s/"/""/g; /^$/d' | \
  # Replace new lines with form feed character
  tr '\n' '\f' | \
  # Remove linebreaks from csv fields
  $cmd_sed $'s/\f\([^<]\)/ \\1/g' | \
  # Replace HTML columns end/start with '","'
  $cmd_sed $'s:</th>\f<th[^>]*>:",":g ; s:</td>\f<td[^>]*>:",":g' | \
  # Replace HTML line end/start with '"'
  $cmd_sed $'s:<th[^>]*>:":g ; s:</th>:":g ; s:<td[^>]*>:":g ; s:</td>:":g' | \
  # Replace form feed character back to new lines
  tr '\f' '\n' | \
  # Remove any other HTML line and empty lines.
  $cmd_sed '/^</d' > "${v_out_file}"
}

fc_replace_file_variable ()
{
  local v_in_file="$1"
  local v_in_attr=$(ere_quote "$2")
  local v_in_repl=$(ere_quote "$3")
  local v_out_file="${v_in_file}.tmp"

  sed "s|${v_in_attr}|${v_in_repl}|g" "${v_in_file}" > "${v_out_file}"

  mv "${v_out_file}" "${v_in_file}"
}