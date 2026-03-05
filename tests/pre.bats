#!/usr/bin/env bats

@test "Verify that we're using Ubuntu or Debian" {
  run bash -c "lsb_release -i | grep -E 'Ubuntu|Debian'"
  [ "$status" -eq 0 ]
}
