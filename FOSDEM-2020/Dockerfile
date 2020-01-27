FROM fedora:31 as builder
LABEL maintainer "Konrad Kleine <kkleine@redhat.com>"
LABEL author "Konrad Kleine <kkleine@redhat.com>"

RUN dnf install -y \
    asymptote \
    ditaa \
    graphviz* \
    librsvg2-tools \
    make \
    mozilla-fira-fonts-common \
    mozilla-fira-mono-fonts \
    mozilla-fira-sans-fonts \
    pandoc \
    python3-pip \
    texlive-ae \
    texlive-appendix \
    texlive-appendixnumberbeamer \
    texlive-babel-english \
    texlive-beamer \
    texlive-beamertheme-metropolis \
    texlive-cm \
    texlive-dejavu \
    texlive-dvisvgm \
    texlive-ec \
    texlive-fira \
    texlive-firamath \
    texlive-font* \
    texlive-fontawesome \
    texlive-framed \
    texlive-gsftopk \
    texlive-lato \
    texlive-listings \
    texlive-lstfiracode \
    texlive-metafont \
    texlive-noto \
    texlive-patchcmd \
    texlive-pstricks \
    texlive-t2 \
    'tex(ulem.sty)' \
  && dnf clean all

RUN dnf install -y texlive-langextra

# RUN locale-gen C.UTF-8
ENV LANG C.UTF-8

# Create a non-root user and a group with the same name: "presenter"
RUN useradd -s /bin/bash presenter

# From here onwards, any RUN, CMD, or ENTRYPOINT will be run under the following user
USER presenter

RUN mkdir -p /home/presenter/talk
WORKDIR /home/presenter/talk
ENV PATH=${PATH}:/home/presenter/.local/bin
RUN pip install --user --quiet \
    pandoc-latex-fontsize \
    pandoc-latex-color \
    pandoc-beamer-block

RUN chown -R presenter:presenter /home/presenter
VOLUME /home/presenter/talk

ENTRYPOINT ["/usr/bin/bash"]