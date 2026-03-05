#!/usr/bin/env bats

@test "Verify /etc/profile.d/initpath.sh exists" {
  run test -f /etc/profile.d/initpath.sh
  [ "$status" -eq 0 ]
}

@test "Verify /etc/profile.d/initpath.sh permissions" {
  run bash -c "stat -c %a /etc/profile.d/initpath.sh | grep '644'"
  [ "$status" -eq 0 ]
}

@test "Verify /etc/profile.d/initpath.sh ownership" {
  run bash -c "stat -c %U:%G /etc/profile.d/initpath.sh | grep 'root:root'"
  [ "$status" -eq 0 ]
}

@test "Verify PATH in /etc/environment" {
  run bash -c "grep 'PATH=' /etc/environment"
  [ "$status" -eq 0 ]
}
