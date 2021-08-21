#!/bin/zsh

function link_local_peer {
    link=$1

    if [ -z "$link" ]
    then
        >&2 echo "provide link"
        return
    fi

    line=$(ping6 "ff02::1%${link}" -c 2 | head -n 3 | tail -n 1)

    #  check line is response from peer
    echo ${line} | grep "icmp_seq=0" >/dev/null || { >&2 echo "peer did not respond"; return; }

    peer="fe80${${line%${link}*}#*fe80}${link}"

    echo $peer
}



