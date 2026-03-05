#!/usr/bin/env bats

@test "Verify fail2ban is installed" {
  run dpkg -s fail2ban
  [ "$status" -eq 0 ]
}

@test "Verify fail2ban jail.local exists" {
  [ -f /etc/fail2ban/jail.local ]
}

@test "Verify fail2ban sshd jail is enabled" {
  run grep -A1 '\[sshd\]' /etc/fail2ban/jail.local
  [ "$status" -eq 0 ]
  [[ "$output" == *"enabled = true"* ]]
}

@test "Verify fail2ban uses ufw as banaction" {
  run grep 'banaction = ufw' /etc/fail2ban/jail.local
  [ "$status" -eq 0 ]
}
