FROM fedora:31 as builder
LABEL maintainer "Konrad Kleine <kkleine@redhat.com>"
LABEL author "Konrad Kleine <kkleine@redhat.com>"
ENV LANG=en_US.utf8

RUN yum install -y \
    texlive-patchcmd \
    texlive-listings \
    texlive-fontawesome \
    texlive-beamer \
    texlive-beamertheme-metropolis \
    pandoc \
    make \
  && yum clean all

RUN yum install -y \
    python3-pip

RUN yum install -y \
    texlive-font*

RUN dnf install -y \
    texlive-metafont \
    texlive-ec

RUN dnf install -y \
    texlive-framed \
    texlive-babel-english \
    texlive-gsftopk

RUN dnf install -y \
    texlive-pstricks

RUN dnf install -y \
    texlive-full \
    texlive-cm \
    texlive-ae \
    texlive-t2

# Create a non-root user and a group with the same name: "presenter"
RUN useradd -s /bin/bash presenter

# From here onwards, any RUN, CMD, or ENTRYPOINT will be run under the following user
USER presenter

RUN mkdir -p /home/presenter/talk
WORKDIR /home/presenter/talk
ENV PATH=${PATH}:/home/presenter/.local/bin
COPY Makefile .
RUN make setup

ENTRYPOINT ["/bin/bash"]