#!/bin/bash
#author leoYuan 20171215
#mail:centos@126.com
#script version 1.5
#kubernetes version 1.7.5
USAGE(){
    echo -e "\n\t$0 [ master | node ]\n"
    exit 1
}
KUBE_OS(){
    #内核设置
    # set net.bridge.bridge-nf-call-iptables = 1 to allow bridge data to be send to iptables for further process.
    ipt=$(grep "net.bridge.bridge-nf-call-iptables" /usr/lib/sysctl.d/00-system.conf |wc -l)
    if [ $ipt -gt 0 ];then
        sed -i '/net.bridge.bridge-nf-call-iptables/d' /usr/lib/sysctl.d/00-system.conf
    fi
    sed -i '$a net.bridge.bridge-nf-call-iptables = 1' /usr/lib/sysctl.d/00-system.conf
    echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
}

KUBE_DOCKER(){
    #安装docker-ce
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y install docker-ce
    systemctl start docker && systemctl enable docker
    #配置中科大docker加速器
    tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
EOF
}

KUBE_KUBE(){
    #安装kube
    tee /etc/yum.repos.d/kube.repo <<-'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF
    yum -y install kubelet kubeadm kubectl kubernetes-cni socat
    #设置kube的cgroup-driver和docker一致，此处为cgroupfs
    sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    #设置pause的仓库地址，否则每次创建pod都无法创建成功
    if ! grep -q KUBELET_POD_INFRA_CONTAINER;then
        sed -i '/Service/a\Environment="KUBELET_POD_INFRA_CONTAINER=--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        sed -i 's#ExecStart=/usr/bin/kubelet.*$#& $KUBELET_POD_INFRA_CONTAINER#' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf  
    fi
    systemctl daemon-reload && systemctl restart kubelet
}

#下载kube相关镜像 https://hub.docker.com/r/warrior/
KUBE_PAUSE(){
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0 gcr.io/google_containers/pause-amd64:3.0
}
KUBE_PROXY(){
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/kube-proxy-amd64:v1.7.5
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/kube-proxy-amd64:v1.7.5 gcr.io/google_containers/kube-proxy-amd64:v1.7.5
}
KUBE_IMAGE(){
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/etcd-amd64:3.0.17
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/etcd-amd64:3.0.17 gcr.io/google_containers/etcd-amd64:3.0.17
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/kube-apiserver-amd64:v1.7.5
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/kube-apiserver-amd64:v1.7.5 gcr.io/google_containers/kube-apiserver-amd64:v1.7.5
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/kube-scheduler-amd64:v1.7.5
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/kube-scheduler-amd64:v1.7.5 gcr.io/google_containers/kube-scheduler-amd64:v1.7.5
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/kube-controller-manager-amd64:v1.7.5
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/kube-controller-manager-amd64:v1.7.5 gcr.io/google_containers/kube-controller-manager-amd64:v1.7.5
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/dnsmasq-metrics-amd64:1.0
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/dnsmasq-metrics-amd64:1.0 gcr.io/google_containers/dnsmasq-metrics-amd64:1.0
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/k8s-dns-kube-dns-amd64:1.14.4
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/k8s-dns-kube-dns-amd64:1.14.4 gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.4
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/k8s-dns-dnsmasq-nanny-amd64:1.14.4
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/k8s-dns-dnsmasq-nanny-amd64:1.14.4 gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.4
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/k8s-dns-sidecar-amd64:1.14.4
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/k8s-dns-sidecar-amd64:1.14.4 gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.4
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/kube-discovery-amd64:1.0
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/kube-discovery-amd64:1.0 gcr.io/google_containers/kube-discovery-amd64:1.0
    docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/exechealthz-amd64:1.2
    docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/exechealthz-amd64:1.2 gcr.io/google_containers/exechealthz-amd64:1.2
}
KUBE_DNS(){
    #查看本地网关
    echo -c "The Server GateWay is ";ip route |grep default|cut -d ' ' -f 3
    #修改默认cluster dns地址，和service-cidr网段保持一致
    sed -i "s#KUBELET_DNS_ARGS=--cluster-dns=192.168.190.150 --cluster-domain=cluster.local#KUBELET_DNS_ARGS=--cluster-dns=172.19.0.10 --cluster-domain=cluster.local#g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    systemctl daemon-reload && systemctl start kubelet.service
}
KUBE_INIT(){
    #kubeadm初始化
    echo "If hang long time then execut 'journalctl -xu|kubeadm' in other tty"
    kubeadm init --kubernetes-version=v1.7.5 --service-cidr 172.19.0.0/20 --skip-preflight-checks --token-ttl 0|tee /root/kubeadm.log
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
}
KUBE_NET(){
    #网络插件calico
    wget -q https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml -O /tmp/calico.yaml
    if [ $? === 0 ];then
        kubectl apply -f /tmp/calico.yaml
    else
        echo -e "Can not download calico.yaml\nhttps://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml"
        exit 1
    fi
}
KUBE_JOIN(){
#这里的token可以kubeadm token generate计算，这里还没做，下次加上。那这个脚本安装node肯定是不行了！！！
     kubeadm join --skip-preflight-checks --token 0xx0c4.fexxxxxxeb529 111.222.333.444:6443
}
NODE_UP(){
    KUBE_OS
    KUBE_DOCKER
    KUBE_PAUSE
    KUBE_PROXY
    KUBE_KUBE
    KUBE_DNS
    KUBE_JOIN
}
MASTER_UP(){
        KUBE_OS
        KUBE_DOCKER
        KUBE_PAUSE
    KUBE_PROXY
    KUBE_IMAGE
        KUBE_KUBE
        KUBE_DNS
    KUBE_INIT
    KUBE_NET
}
if [ $# -eq 1 ];then
    case $1 in
        'master') MASTER_UP ;;
        'node') NODE_UP ;;
        '*') USAGE ;;
    esac
else
    USAGE 
fi
