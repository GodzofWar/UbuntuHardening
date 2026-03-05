#!/usr/bin/env bats

@test "Verify /etc/hosts.equiv does not exist" {
  run test -f /etc/hosts.equiv
  [ "$status" -eq 1 ]
}

@test "Verify no .rhosts files exist in home directories" {
  run bash -c "find /home/ -name '.rhosts' 2>/dev/null | wc -l | grep '^0$'"
  [ "$status" -eq 0 ]
}
