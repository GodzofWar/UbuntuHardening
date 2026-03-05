#!/usr/bin/env bats

@test "Verify that we're using Ubuntu or Debian" {
  run bash -c "grep -qE '^ID=(ubuntu|debian)' /etc/os-release"
  [ "$status" -eq 0 ]
}
