# Authors: Vladimir Loskutov, Matthew Martin
# no python

FROM ubuntu:18.04

LABEL Description="Stanford NLP" Vendor="N/A" Version="0.1.0"

# Install base apt packages

# RUN apt-get install -y --no-install-recommends autoconf automake build-essential curl git libsnappy-dev libtool pkg-config sudo && \
#    apt-get install -y --no-install-recommends python3-distutils python3-dev && \
# I think htop depends on python
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -y openjdk-8-jre && \
    apt-get install -y p7zip-full && \
    apt-get install -y --no-install-recommends sudo curl ca-certificates byobu  && \
    apt-get install -y --no-install-recommends nano \
                        wget ufw net-tools iptables unattended-upgrades netcat && \
    # apt-get install -y --no-install-recommends openssh-server && \
    rm -rf /var/lib/apt/lists/* && apt-get autoremove

#    curl https://bootstrap.pypa.io/get-pip.py | python3.6 && \
#    pip3 install --upgrade pip  && pip3 install wheel pipenv

RUN echo 'APT::Periodic::Update-Package-Lists "1";' >> /etc/apt/apt.conf.d/10periodic  && \
    echo 'APT::Periodic::Download-Upgradeable-Packages "1";' >> /etc/apt/apt.conf.d/10periodic && \
    echo 'APT::Periodic::AutocleanInterval "7";' >> /etc/apt/apt.conf.d/10periodic  && \
    echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/10periodic

# Create user

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HISTFILESIZE=1500
ENV HISTSIZE=1500

RUN useradd -ms /bin/bash stanford_nlp
RUN adduser stanford_nlp sudo
RUN echo "stanford_nlp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER stanford_nlp
CMD ["/bin/bash"]
WORKDIR /home/stanford_nlp
ENV HOME /home/stanford_nlp
RUN wget https://nlp.stanford.edu/software/stanford-corenlp-full-2017-06-09.zip && \
    7z x stanford-corenlp-full-2017-06-09.zip
WORKDIR /home/stanford_nlp/stanford-corenlp-full-2017-06-09/
RUN   wget https://nlp.stanford.edu/software/stanford-english-corenlp-2017-06-09-models.jar && \
      wget https://nlp.stanford.edu/software/stanford-english-kbp-corenlp-2017-06-09-models.jar
RUN wget https://nlp.stanford.edu/software/stanford-arabic-corenlp-2017-06-09-models.jar && \
     wget https://nlp.stanford.edu/software/stanford-chinese-corenlp-2017-06-09-models.jar
RUN  wget https://nlp.stanford.edu/software/stanford-french-corenlp-2017-06-09-models.jar && \
     wget https://nlp.stanford.edu/software/stanford-german-corenlp-2017-06-09-models.jar && \
     wget https://nlp.stanford.edu/software/stanford-spanish-corenlp-2017-06-09-models.jar
WORKDIR /home/stanford_nlp

# Deploy app
COPY start_nlp.sh /home/stanford_nlp/app/
WORKDIR /home/stanford_nlp/app

RUN sudo chown stanford_nlp:stanford_nlp start_nlp.sh
RUN sudo chmod u+x start_nlp.sh

ENTRYPOINT ["/usr/bin/env", "bash"]
CMD ["./start_nlp.sh"]

EXPOSE 9000

# If you need ssh access to container then uncomment code below to generate key and configure ssh daemon

# RUN CONFIG=/etc/ssh/sshd_config ;\
#     DEFAULTS=/etc/ssh/sshd_config.factory-defaults ;\
#     if [ ! -f "$DEFAULTS" ]; then \
#         cp "$CONFIG" "$DEFAULTS" \
#         chmod a-w "$DEFAULTS" ;\
#     fi ;\
#     # change PasswordAuthentication to no
#     sed -i "s/[ \t]*#[ \t]*PasswordAuthentication[ \t]*yes/PasswordAuthentication no/" "$CONFIG" ;\
#     cat $CONFIG | grep PasswordAuthentication ;\
#     systemctl enable ssh ;\
#     service ssh start

# COPY stanford_nlp.pem.pub /stanford_nlp.pub
# RUN USER="stanford_nlp" ;\
#     mkdir .ssh ;\
#     chmod 700 .ssh ;\
#     touch /home/"$USER"/.ssh/authorized_keys ;\
#     chmod 600 /home/"$USER"/.ssh/authorized_keys ;\
#     cat /"$USER".pub >> /home/"$USER"/.ssh/authorized_keys
