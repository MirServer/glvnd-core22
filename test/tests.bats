#!/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    TESTS_DIR="$( readlink -f "$( dirname "$BATS_TEST_FILENAME" )" )"

    source ${TESTS_DIR}/../setup-graphics-core22-env
    # Simplify running the script by adding the source directory to $PATH
    PATH=${TESTS_DIR}/../:${PATH}
}

@test "parse_file returns associative array" {
  declare -A parsed_lines
  parse_file parsed_lines <<EOF
FOO=bar
BAZ=quux
EOF
  assert_equal "${parsed_lines['FOO']}" "bar"
  assert_equal "${parsed_lines['BAZ']}" "quux"
}

@test "parse_file handles values containing '='" {
  declare -A parsed_lines
  parse_file parsed_lines <<EOF
FOO=a=value=containing=equals
EOF
  assert_equal "${parsed_lines['FOO']}" "a=value=containing=equals"
}

@test "script executes its argument" {
  run setup-graphics-core22-env ${TESTS_DIR}/test_executable
  assert_output --partial "Test run"
}

@test "script passes further arguments to the executed command" {
  run setup-graphics-core22-env ${TESTS_DIR}/test_executable "Yo!"
  assert_line "Yo!"
}

@test "script passes further arguments to the executed command separately" {
  run setup-graphics-core22-env ${TESTS_DIR}/test_executable "Yo!" "Two Too"
  assert_line "Yo!"
  assert_line "Two Too"
}

@test "append_environment adds new environment variable" {
  declare -A requested_variables=( [GREETING]=hello )
  append_environment requested_variables
  assert_equal "${GREETING}" "hello"
}

@test "append_environment extends existing environment variable" {
  declare -A requested_variables=( [LD_LIBRARY_PATH]=graphics/lib )
  LD_LIBRARY_PATH=/usr/lib
  append_environment requested_variables
  assert_equal "${LD_LIBRARY_PATH}" "/usr/lib:graphics/lib"
}

@test "append_environment adds/extends multiple variables" {
  declare -A requested_variables=( [LD_LIBRARY_PATH]=graphics/lib [FOO]=bar )
  LD_LIBRARY_PATH=/usr/lib
  append_environment requested_variables
  assert_equal "${LD_LIBRARY_PATH}" "/usr/lib:graphics/lib"
  assert_equal "${FOO}" "bar"
}

@test "prepend_environment adds new environment variable" {
  declare -A requested_variables=( [GREETING]=hello )
  prepend_environment requested_variables
  assert_equal "${GREETING}" "hello"
}

@test "prepend_environment extends existing environment variable" {
  declare -A requested_variables=( [LD_LIBRARY_PATH]=graphics/lib)
  LD_LIBRARY_PATH=/usr/lib
  prepend_environment requested_variables
  assert_equal "${LD_LIBRARY_PATH}" "graphics/lib:/usr/lib"
}

@test "prepend_environment adds/extends multiple variables" {
  declare -A requested_variables=( [LD_LIBRARY_PATH]=graphics/lib [FOO]=bar )
  LD_LIBRARY_PATH=/usr/lib
  prepend_environment requested_variables
  assert_equal "${LD_LIBRARY_PATH}" "graphics/lib:/usr/lib"
  assert_equal "${FOO}" "bar"
}
