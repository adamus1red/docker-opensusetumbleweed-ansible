FROM opensuse/tumbleweed:latest
LABEL maintainer="Jeff Geerling"

ENV DEBIAN_FRONTEND noninteractive

ENV pip_packages "ansible cryptography"

# Install dependencies.
RUN zypper refresh \
    && zypper dup -y \
    && zypper in -t pattern devel_python3 \
    && zypper install -y \
       sudo wget libffi-devel libssl-devel \
       python2-pip python3-pip python2-devel python3-devel \
       python2-setuptools python3-setuptools python2-wheel \
       python3-wheel \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && zypper clean \
    && wget https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py

# Install Ansible via pip.
RUN pip install $pip_packages

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
