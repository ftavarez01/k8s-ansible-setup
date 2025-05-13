#!/bin/bash
#########################################################
# Kubernetes Servers                                    #
# OS: Kubernetes Servers: Ubuntu 24.4                   #  
# OS Ansible Server: Ubuntu 24.4                        #
# Controlplane                                          #
#     # IP: put ip controlplane or master               #
# Workers 1                                             #
#   # IP:  ( put IP workers 1 )                         #
# Workers 2                                             #
#   # IP: put IP workers 2                              #
# Ansible                                               #
    # IP Put IP Ansible                                 #
#########################################################
#Variables
REMOTE_USER="root" # root user on remote Kubernetes Server
REMOTE_IP_ADDRESS_SERVERS="controlplane worker1 worker2"  ## Host Kubernetes Servers ( master,workers ).
# **Important Note:** The logical names defined above (controlplane, worker1, worker2)
# must be resolvable by the system where this script is executed. This can be configured
# through DNS or by adding entries to the /etc/hosts file.
#
SSH_DIRECTORY="/root/.ssh" # SSH DIRECTORY LOCAL AND REMOTE
PRIVATE_KEYS_LOCAL="id_rsa"
PUBLIC_KEYS_LOCAL="id_rsa.pub"
#
# create authentication keys on Kubernetes servers and to configure SSH key authentication . ssh without password
# Generating SSH key in the path /root/.ssh/id_rsa.pub
#
if [ ! -d $SSH_DIRECTORY ];
then
     mkdir $SSH_DIRECTORY && chmod 700 $SSH_DIRECTORY
else
	echo "Directory .SSH Exists on Ansible Server"
fi

if [ ! -e "$SSH_DIRECTORY/$PRIVATE_KEYS_LOCAL" ];
then

     echo "Creating ssh keys on Ansible Server"

     ssh-keygen -t rsa -f $SSH_DIRECTORY/$PRIVATE_KEYS_LOCAL -q
else
	 echo "SSH keys already exist on Ansible Server."
fi
#
#  Check if ssh public key exists Verificar
if [ ! -f "$SSH_DIRECTORY/$PUBLIC_KEYS_LOCAL" ]; then
  echo "Error: Public keys not found $PUBLIC_KEYS_LOCAL"
  exit 1
fi

# Iterate over remote Servers for kubernetes
for REMOTE_SERVERS in $REMOTE_IP_ADDRESS_SERVERS; do
  echo "Configuring ssh keys for $REMOTE_USER on $REMOTE_SERVERS..."

  # Create .ssh directory If doesn't exists
  ssh -n -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_SERVERS "mkdir -p $SSH_DIRECTORY && chmod 700 $SSH_DIRECTORY"
  if [ $? -ne 0 ]; then
    echo "Error: wasn't possible to create ssh directory  $SSH_DIRECTORY ON $REMOTE_SERVERS"
    continue # Jump to another Servers
  fi

  # Copy the ssh keys to authorized_keys file
  ssh $REMOTE_USER@$REMOTE_SERVERS "cat >> $SSH_DIRECTORY/authorized_keys" < "$SSH_DIRECTORY/$PUBLIC_KEYS_LOCAL"
  if [ $? -ne 0 ]; then
    echo "  Error: wasn't possible to copy ssh keys to copiar $REMOTE_SERVERS"
    continue # Jump to another Servers
  fi

  # Set correct permission on  authorized_keys file
  ssh $REMOTE_USER@$REMOTE_SERVERS "chmod 600 $SSH_DIRECTORY/authorized_keys"
  if [ $? -ne 0 ]; then
    echo "  Error: wasn't set correct permission on $REMOTE_SERVERS"
    continue # Jump to another Servers
  fi

  echo "SSH Keys configured correctly on $REMOTE_SERVERS"
done

echo "Configuration completed successfully for kubernetes Servers. ( Happy Devops Day.. )"
echo  "Bye Devops..."

