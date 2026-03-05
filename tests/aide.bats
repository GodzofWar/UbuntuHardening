#!/usr/bin/env bats

@test "Verify aide scheduled check is present" {
  run bash -c "stat /etc/cron.daily/aide || systemctl is-enabled aidecheck.timer"
  [ "$status" -eq 0 ]
}

@test "Verify aide Checksums is set to sha512" {
  run bash -c "grep '^Checksums = sha512' /etc/aide/aide.conf"
  [ "$status" -eq 0 ]
}

@test "Verify aide excludes /var/lib/lxcfs/cgroup" {
  run bash -c "grep -r '!/var/lib/lxcfs/cgroup' /etc/aide/aide.conf.d/"
  [ "$status" -eq 0 ]
}

@test "Verify aide excludes /var/lib/docker" {
  run bash -c "grep -r '!/var/lib/docker' /etc/aide/aide.conf.d/"
  [ "$status" -eq 0 ]
}
