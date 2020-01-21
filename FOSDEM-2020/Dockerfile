FROM fedora:31 as builder
LABEL maintainer "Konrad Kleine <kkleine@redhat.com>"
LABEL author "Konrad Kleine <kkleine@redhat.com>"

RUN dnf install -y \
    ditaa \
    graphviz* \
    librsvg2-tools \
    make \
    pandoc \
    python3-pip \
    texlive-ae \
    texlive-babel-english \
    texlive-beamer \
    texlive-beamertheme-metropolis \
    texlive-cm \
    texlive-dejavu \
    texlive-ec \
    texlive-font* \
    texlive-fontawesome \
    texlive-framed \
    texlive-gsftopk \
    texlive-lato \
    texlive-listings \
    texlive-metafont \
    texlive-noto \
    texlive-patchcmd \
    texlive-pstricks \
    texlive-t2 \
  && dnf clean all

RUN locale-gen C.UTF-8
ENV LANG C.UTF-8

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
