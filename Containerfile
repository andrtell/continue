# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Args
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ARG FEDORA_VERSION=37

ARG BUILDER_IMAGE="fedora:${FEDORA_VERSION}"
ARG RUNNER_IMAGE="fedora:${FEDORA_VERSION}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Build
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROM ${BUILDER_IMAGE} as builder

RUN dnf -y update && \
    dnf -y install  procps util-linux \
                    make automake gcc gcc-c++ kernel-devel \
                    langpacks-en \
                    erlang-xmerl \
                    git elixir && \
    dnf clean all && \ 
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"
 
COPY mix.exs mix.lock ./

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/

RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

RUN mix assets.deploy
RUN mix compile

COPY config/runtime.exs config/
COPY rel rel

RUN mix release

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Runner
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROM ${RUNNER_IMAGE}

RUN dnf -y update && \
    rpm --setcaps shadow-utils 2>/dev/null && \
    dnf -y install podman fuse-overlayfs \
           libstdc++ openssl ncurses-libs \
           glibc-langpack-en git openssl1.1 libgcrypt \ 
           --exclude container-selinux && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN useradd container; \
echo -e "container:1:999\ncontainer:1001:64535" > /etc/subuid; \
echo -e "container:1:999\ncontainer:1001:64535" > /etc/subgid;

ARG _REPO_URL="https://raw.githubusercontent.com/containers/podman/main/contrib/podmanimage/stable"

ADD $_REPO_URL/containers.conf /etc/containers/containers.conf
ADD $_REPO_URL/podman-containers.conf /home/container/.config/containers/containers.conf

RUN mkdir -p /home/container/.local/share/containers && \
    chown container:container -R /home/container && \
    chmod 644 /etc/containers/containers.conf

RUN sed -e 's|^#mount_program|mount_program|g' \
           -e '/additionalimage.*/a "/var/lib/shared",' \
           -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
           /usr/share/containers/storage.conf \
           > /etc/containers/storage.conf

VOLUME /var/lib/containers
VOLUME /home/containers/.local/share/containers

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

WORKDIR "/app"

RUN chown nobody /app

ENV MIX_ENV="prod"

COPY --from=builder --chown=container:root /app/_build/${MIX_ENV}/rel/continue ./

RUN ln -s /app/bin/continue /app/bin/app

USER container

CMD ["/app/bin/server"]
