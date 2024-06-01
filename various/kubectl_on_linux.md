# Install kubectl on Linux

## Install on Ubuntu 24.04

"manual" installation:

    curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

test with (also as non root):
    kubectl version --client --output=yaml

finish the installation (non-root):
    echo 'source <(kubectl completion bash)' >>~/.bashrc
    kubectl completion bash
    mkdir ~/.kube
    vi ~/.kube/config_t3
    cp ~/.kube/config_t3 ~/.kube/config
    echo -e "alias k='/usr/local/bin/kubectl'" >> ~/.profile

test:
    k get no
    

## see also

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

