# /etc/profile.d/lshi-env.sh
# chmod +x !$

# my shell
export VPN_PATH=/home/lshi/workspace/mysh
export PATH=$PATH:$VPN_PATH

# python - pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# go
export GOROOT=/usr/local/go1.15.6
export GOPATH=/home/lshi/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# node
export NODEPATH=/usr/local/node-v12.13.0-linux-x64
export PATH=$PATH:$NODEPATH/bin

# julia
export JULIA=/usr/local/julia-1.5.3
export PATH=$PATH:$JULIA/bin

# postman
export postman=/usr/local/Postman
export PATH=$PATH:$postman/app

# ulimit
ulimit -n 65535

# java for TongWeb
export JAVA_HOME=/home/lshi/jdk1.8.0_172
export JRE_HOME=${JAVA_HOME}/jre
export PATH=$PATH:$JAVA_HOME/bin:${JRE_HOME}/bin

# gradle
export GRADLE_HOME=/usr/local/gradle-6.8
export PATH=$PATH:$GRADLE_HOME/bin

# Android SDK
export ANDROID_HOME=/home/lshi/Android/Sdk
export ANDROID_SDK_ROOT=${ANDROID_HOME}platform-tools
export PATH=$PATH:$ANDROID_HOME/tools:${ANDROID_SDK_ROOT}

## alias
alias lls="ls | lolcat"
alias lll="ll | lolcat"
alias cat="lolcat -F 0.01"
