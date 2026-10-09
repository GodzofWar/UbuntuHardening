#!/usr/bin/env bats

load test_helper

@test "Ensure a non-root account with sudo privileges exists" {
  run bash -c "getent group sudo admin | cut -d: -f4 | tr ',' '\n' | grep -vE '^(root)?$'"
  [ "$status" -eq 0 ]
}

@test "Ensure at least one group allowed by sshd has members" {
  run bash -c "for g in \$(sshd -T | awk '/^allowgroups/ {\$1=\"\"; print}'); do getent group \"\$g\" | cut -d: -f4 | grep -q . && exit 0; getent passwd | awk -F: -v gid=\"\$(getent group \"\$g\" | cut -d: -f3)\" '\$4 == gid' | grep -q . && exit 0; done; exit 1"
  [ "$status" -eq 0 ]
}

@test "Ensure an SSH-allowed account has a public key when password authentication is disabled" {
  run bash -c "sshd -T | grep -q '^passwordauthentication no' || exit 0; for g in \$(sshd -T | awk '/^allowgroups/ {\$1=\"\"; print}'); do for u in \$(getent group \"\$g\" | cut -d: -f4 | tr ',' ' ') \$(getent passwd | awk -F: -v gid=\"\$(getent group \"\$g\" | cut -d: -f3)\" '\$4 == gid {print \$1}'); do h=\$(getent passwd \"\$u\" | cut -d: -f6); grep -v '^[[:space:]]*#' \"\$h/.ssh/authorized_keys\" 2>/dev/null | grep -qE '(ssh-(rsa|ed25519)|ecdsa-sha2-nistp|sk-)' && exit 0; done; done; exit 1"
  [ "$status" -eq 0 ]
}

@test "Ensure SSH port $SSH_PORT is reachable through UFW" {
  run bash -c "ufw status | grep -E '^$SSH_PORT/tcp +(ALLOW|LIMIT)'"
  [ "$status" -eq 0 ]
}

@test "Ensure the OpenSSH configuration is valid" {
  run sshd -t
  [ "$status" -eq 0 ]
}
