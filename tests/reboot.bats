#!/usr/bin/env bats

@test "Verify update-notifier-common provides reboot-required check" {
  run test -x /usr/lib/update-notifier/update-motd-reboot-required
  [ "$status" -eq 0 ]
}
