#!/bin/zsh

# TODO: improve parameter and error handling

## enable docker to open tcp socket on port 2376
## expect the ssh connection to be of a sudoers user
## WARNING: opens up unsecured docker endpoint
function add_context_for_remote {
    CONTEXT_NAME=$1

    if [ "${CONTEXT_NAME}" = "" ]
    then
        echo "provide CONTEXT_NAME to connect to"
        return -1
    fi

    HOST=$2
    USER=$3

    SSH_CONNECTION="${USER}@${HOST}"

    if [ "${SSH_CONNECTION}" = "" ]
    then
        echo "provide SSH_CONNECTION to connect to"
        return -1
    fi


    ssh "${SSH_CONNECTION}" "
        sudo mkdir -p /etc/systemd/system/docker.service.d
        cat <<EOM > /tmp/startup_options.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
EOM

    sudo mv /tmp/startup_options.conf /etc/systemd/system/docker.service.d/startup_options.conf
    sudo systemctl daemon-reload
    sudo systemctl restart docker.service
    "

    docker context create "${CONTEXT_NAME}" --docker "host=tcp://${HOST}:2376"
}

function remove_context_for_remote {
    CONTEXT_NAME=$1

    if [ "${CONTEXT_NAME}" = "" ]
    then
        echo "provide CONTEXT_NAME to connect to"
        return -1
    fi

    HOST=$2
    USER=$3

    SSH_CONNECTION="${USER}@${HOST}"

    if [ "${SSH_CONNECTION}" = "" ]
    then
        echo "provide SSH_CONNECTION to connect to"
        return -1
    fi

    docker context rm "${CONTEXT_NAME}"

    ssh "${SSH_CONNECTION}" \
        "sudo rm /etc/systemd/system/docker.service.d/startup_options.conf
         sudo systemctl daemon-reload
         sudo systemctl restart docker.service
        "
}