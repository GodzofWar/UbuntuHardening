#!/usr/bin/env bats

load test_helper

@test "Verify that prelink is not installed" {
  run packageInstalled 'prelink'
  [ "$status" -eq 1 ]
}
