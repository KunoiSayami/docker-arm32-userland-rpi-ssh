FROM rpicamera:latest

RUN apt-get update

RUN apt-get install -y \
        openssh-server \
        vim \
        sudo \
        tzdata; \
    apt-get clean;

RUN apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-wheel \
        python3-setuptools \
        python3-dev; \
    apt-get clean;

RUN apt-get install -y --no-install-recommends \
        gcc; \
    apt-get clean;

# install module in global
RUN python3 -m pip install picamera aiohttp

RUN apt-get --purge --auto-remove remove -y gcc;

RUN rm -rf /root/.cache/

# sshd
RUN mkdir /var/run/sshd; \
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    apt-get clean;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'sudo ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "user:${USER_PASSWORD}" | sudo chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

RUN useradd -m -s /bin/bash user

RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

RUN mkdir /home/user/.ssh

WORKDIR /home/user

USER user

ENV USER_PASSWORD user

ENV TZ Asia/Taipei

ENTRYPOINT ["entry_point.sh"]
CMD ["sudo", "/usr/sbin/sshd", "-D", "-e"]


