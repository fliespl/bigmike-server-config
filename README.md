First steps
====================
- login as root
- apt-get install software-properties-common && apt-add-repository ppa:ansible/ansible -y && apt update && apt upgrade -y
- git config --global user.name ""
- git config --global user.email 
- apt install -y etckeeper ansible
- git clone git@github.com:fliespl/bigmike-server-config.git /ansible
- cd /ansible
- ansible-playbook -i hosts site.yml