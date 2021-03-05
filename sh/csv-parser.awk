##
# Copyright © 2013 Geoffroy Aubry <geoffroy.aubry@free.fr>
#
# This file is part of awk-csv-parser.
#
# awk-csv-parser is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# awk-csv-parser is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with awk-csv-parser.  If not, see <http://www.gnu.org/licenses/>
#

# New Functions by Rodrigo Jorge < www.dbarj.com.br > at December-2017

##
# Extract next field on specified CSV record.
#
# @param string record  CSV record to parse.
# @param int pos        Position at which search start.
# @param char separator Field separator.
# @param char quote     Field enclosure.
# @param array csv      Array of found fields in which store the next field (passed by reference).
# @param int num_fields Number of fieds already found.
# @return int           Last index of parsed character in CSV record,
#                       or negative error code (error message in csv_error).
#
function csv_parse_field (record, pos, separator, quote, csv, num_fields) {
    if (substr(record, pos, 1) == quote) {
        quoted=1
        pos++
    } else {
        quoted=0
    }
    prev_char_is_quote=0
    field=""

    while (pos <= length(record)) {
        c = substr(record, pos, 1)
        if (c == separator && (! quoted || prev_char_is_quote)) {
            csv[num_fields] = field
            return ++pos
        } else if (c == quote) {
            if (! quoted) {
                csv_error="Missing opening quote before '" field "' in following record: '" record "'"
                return -1
            } else if (prev_char_is_quote) {
                prev_char_is_quote=0
                field = field quote
            } else {
                if (pos == length(record)) {
                    quoted=0
                } else {
                    prev_char_is_quote=1
                }
            }
        } else if (prev_char_is_quote) {
            csv_error="Missing separator after '" field "' in following record: '" record "'"
            return -2
        } else {
            field = field c
        }
        pos++
    }

    if (quoted) {
        csv_error="Missing closing quote after '" field "' in following record: '" record "'"
        return -3
    } else {
        csv[num_fields] = field
        return pos
    }
}

##
# Parse CSV record.
#
# @param string record  CSV record to parse.
# @param char separator Field separator.
# @param char quote     Field enclosure.
# @param array csv      Empty array in which store all fields (passed by reference).
# @return int           Number of fields parsed in CSV record,
#                       or negative error code (error message in csv_error).
#
function csv_parse_record (record, separator, quote, csv) {
    if (length(record) == 0) {
        return
    }

    pos=1
    num_fields=0
    while (pos <= length(record)) {
        pos = csv_parse_field(record, pos, separator, quote, csv, num_fields)
        if (pos < 0) {
            print "\033[0;31m[CSV ERROR: " (-pos) "] \033[1;31m" csv_error "\033[0m"
            return pos
        }
        num_fields++
    }

    if (substr(record, length(record), 1) == separator) {
        csv[num_fields++]=""
    }

    return num_fields
}

##
# Parse CSV record, then display it without quote and replacing specified separator by output_fs.
#
# @param string record    CSV record to parse.
# @param char separator   Field separator.
# @param char quote       Field enclosure.
# @param string output_fs Output field enclosure.
# @return int             Return 0 if no error, else return positive error code.
#
function csv_parse_and_display (record, separator, quote, output_fs) {
    num_fields=csv_parse_record($0, separator, quote, csv)
    if (num_fields >= 0) {
        line=""
        for (i=0; i<num_fields; i++) {
            line=line csv[i]
            if ( i < num_fields-1) {
                line=line output_fs
            }
        }
        print line
        return 0
    } else {    # Return error code:
        return -num_fields
    }
}

##########################################
##########################################
##########################################

## Functions included and created by Rodrigo Jorge

# Same as csv_parse_field_asis but keep separators and quotes as is
function csv_parse_field_asis (record, pos, separator, quote, csv, num_fields) {
    prev_char_is_quote=0
    field=""
    if (substr(record, pos, 1) == quote) {
        field=quote
        quoted=1
        pos++
    } else {
        quoted=0
    }

    while (pos <= length(record)) {
        c = substr(record, pos, 1)
        if (c == separator && (! quoted || prev_char_is_quote)) {
            if (prev_char_is_quote) field = field quote
            csv[num_fields] = field
            return ++pos
        } else if (c == quote) {
            if (! quoted) {
                csv_error="Missing opening quote before '" field "' in following record: '" record "'"
                return -1
            } else if (prev_char_is_quote) {
                prev_char_is_quote=0
                field = field quote quote
            } else {
                if (pos == length(record)) {
                    field = field quote
                    quoted=0
                } else {
                    prev_char_is_quote=1
                }
            }
        } else if (prev_char_is_quote) {
            csv_error="Missing separator after '" field "' in following record: '" record "'"
            return -2
        } else {
            field = field c
        }
        pos++
    }

    if (quoted) {
        csv_error="Missing closing quote after '" field "' in following record: '" record "'"
        return -3
    } else {
        csv[num_fields] = field
        return pos
    }
}

# Same as csv_parse_record but keep separators and quotes as is
function csv_parse_record_asis (record, separator, quote, csv) {
    if (length(record) == 0) {
        return
    }

    pos=1
    num_fields=0
    while (pos <= length(record)) {
        pos = csv_parse_field_asis(record, pos, separator, quote, csv, num_fields)
        if (pos < 0) {
            print "\033[0;31m[CSV ERROR: " (-pos) "] \033[1;31m" csv_error "\033[0m"
            return pos
        }
        num_fields++
    }

    if (substr(record, length(record), 1) == separator) {
        csv[num_fields++]=""
    }

    return num_fields
}

## Skip everything after field given in parameter
function csv_print_until_field_record (record, separator, quote, last_field) {
    last_field--
    num_fields=csv_parse_record_asis(record, separator, quote, csv)
    cur_field=0
    output=""
    while (cur_field <= last_field && cur_field <= num_fields-1) {
        if (cur_field != 0) output=output separator
        output=output csv[cur_field]
        cur_field++
    }
    print output
    return cur_field
}

## Skip field given in parameter
function csv_print_skip_field_record (record, separator, quote, skip_field) {
    skip_field--
    num_fields=csv_parse_record_asis(record, separator, quote, csv)
    cur_field=0
    output=""
    first_print=1
    while (cur_field <= num_fields-1) {
        if (cur_field != skip_field)
        {
            if (first_print)
            {
                first_print=0
                output=csv[cur_field]
            } else {
                output=output separator csv[cur_field]
            }
        }
        cur_field++
    }
    print output
    num_fields--
    return num_fields
}


## Replace values of field_pos by the value "rep_value".
function csv_print_enquote_field (record, separator, quote, field_pos, enquote) {
    field_pos--
    num_fields=csv_parse_record(record, separator, quote, csv)
    output=""
    for (i=0; i<num_fields; i++) {
        if (i == field_pos) {
            print_value=enquote csv[i] enquote
        } else {
            print_value=csv[i]
        }
        if (i != 0) output=output separator
        output=output print_value
    }
    print output
    return num_fields
}