#!/usr/bin/env bats

@test "Verify /etc/issue exists and contains authorized use notice" {
  run bash -c "grep 'authorized use only' /etc/issue"
  [ "$status" -eq 0 ]
}

@test "Verify /etc/issue.net exists and contains authorized use notice" {
  run bash -c "grep 'authorized use only' /etc/issue.net"
  [ "$status" -eq 0 ]
}

@test "Verify /etc/motd exists and contains authorized use notice" {
  run bash -c "grep 'authorized use only' /etc/motd"
  [ "$status" -eq 0 ]
}

@test "Verify /etc/update-motd.d/ scripts are not executable" {
  run bash -c "find /etc/update-motd.d/ -type f -executable | wc -l | grep '^0$'"
  [ "$status" -eq 0 ]
}
