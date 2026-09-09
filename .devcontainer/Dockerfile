FROM quay.io/fedora/fedora-minimal:latest

RUN dnf install -y \
        bash-completion \
        dbus-x11 \
        gettext \
        git \
        jq \
        kf6-kirigami \
        libksysguard \
        libplasma \
        plasma-desktop \
        plasma-sdk \
        qt6-qtdeclarative-devel \
        ShellCheck \
        sudo \
        tar \
        vim \
        which \
        zip \
    && dnf clean -y all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/*

# add non-root user
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} --create-home ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

# add bash-git-prompt
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1 \
    && echo -e 'if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then\n    source $HOME/.bash-git-prompt/gitprompt.sh\nfi\n' >> ~/.bashrc
