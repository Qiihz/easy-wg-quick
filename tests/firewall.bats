#!/usr/bin/env bats

load teardown setup

@test "run with firewall type set to Linux netfilter" {
    echo iptables > fwtype.txt
    run ../easy-wg-quick
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 10 ]
    run grep 'iptables -A FORWARD' wghub.conf
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "PostUp = iptables -I DOCKER-USER -i %i -j ACCEPT || iptables -A FORWARD -i %i -j ACCEPT" ]
}

@test "run with firewall type set to firewalld" {
    echo firewalld > fwtype.txt
    echo 31337 > portno.txt
    run ../easy-wg-quick
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 10 ]
    run grep 'firewall-cmd --zone=public' wghub.conf
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 4 ]
    [ "${lines[0]}" == "PostUp = firewall-cmd --zone=public --add-port 31337/udp" ]
    [ "${lines[1]}" == "PostUp = firewall-cmd --zone=public --add-masquerade" ]
    [ "${lines[2]}" == "PostDown = firewall-cmd --zone=public --remove-port 31337/udp" ]
    [ "${lines[3]}" == "PostDown = firewall-cmd --zone=public --remove-masquerade" ]
}

@test "run with firewall type set to OpenBSD PF" {
    echo pf > fwtype.txt
    run ../easy-wg-quick
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 10 ]
    run grep 'pfctl -e' wghub.conf
    [ "$status" -eq 0 ]
    [ "$output" == "PostUp = pfctl -e" ]
}

@test "run with firewall type set to custom" {
    echo custom > fwtype.txt
    echo "PostUp = custom_fw reload" > commands.txt
    run ../easy-wg-quick
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 10 ]
    run grep 'custom_fw reload' wghub.conf
    [ "$status" -eq 0 ]
    [ "$output" == "PostUp = custom_fw reload" ]
}

@test "run with firewall type set to none" {
    echo none > fwtype.txt
    run ../easy-wg-quick
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 10 ]
    run grep 'iptables' wghub.conf
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 0 ]
    run grep 'pfctl' wghub.conf
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 0 ]
    run grep 'custom_fw reload' wghub.conf
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 0 ]
}
