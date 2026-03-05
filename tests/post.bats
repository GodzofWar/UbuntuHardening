#!/usr/bin/env bats

load test_helper

@test "Verify that fwupd is installed" {
  run packageInstalled 'fwupd'
  [ "$status" -eq 0 ]
}

@test "Verify /boot config file permissions" {
  run bash -c "find /boot/ -type f -name '*.cfg' -perm /133 | wc -l | grep '^0$'"
  [ "$status" -eq 0 ]
}
