#!/usr/bin/env bats

@test "Verify hardening config files exist" {
  for conf in hardening-sshd.conf hardening-postfix.conf hardening-psad.conf hardening-rsyslog.conf hardening-auditd.conf hardening-unattended-upgrades.conf; do
    [ -f "config/${conf}" ]
  done
}

@test "Verify SSH service has hardening override" {
  if [ -d /etc/systemd/system/ssh.service.d ]; then
    [ -f /etc/systemd/system/ssh.service.d/hardening.conf ]
  elif [ -d /etc/systemd/system/sshd.service.d ]; then
    [ -f /etc/systemd/system/sshd.service.d/hardening.conf ]
  else
    skip "SSH service override directory not found"
  fi
}

@test "Verify hardening overrides contain ProtectSystem" {
  for conf in config/hardening-*.conf; do
    run grep -q "ProtectSystem=" "$conf"
    [ "$status" -eq 0 ]
  done
}

@test "Verify hardening overrides contain PrivateTmp" {
  for conf in config/hardening-*.conf; do
    run grep -q "PrivateTmp=yes" "$conf"
    [ "$status" -eq 0 ]
  done
}
