ARG SWIFTVERSION=5.8.1
ARG UBUNTUDISTRO=jammy

FROM swift:${SWIFTVERSION}-${UBUNTUDISTRO} AS sysroot

WORKDIR /opt/d2

# Install build dependencies into target sysroot
COPY Scripts/install-build-dependencies-apt Scripts/
RUN Scripts/install-build-dependencies-apt && rm -rf /var/lib/apt/lists/*

FROM --platform=$BUILDPLATFORM swift:${SWIFTVERSION}-${UBUNTUDISTRO} AS builder

ARG SWIFTVERSION
ARG UBUNTUDISTRO
ARG BUILDARCH
ARG TARGETARCH

ARG TARGETSYSROOT=/usr/${TARGETARCH}-ubuntu-${UBUNTUDISTRO}

WORKDIR /opt/d2

# Copy target sysroot into builder
# TODO: Only copy stuff that we need for compilation (/usr/lib, /usr/include etc.)
COPY --from=sysroot / ${TARGETSYSROOT}

# (Cross-)compile D2
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.resolved ./
COPY Scripts/build-release Scripts/get-linux-arch-name Scripts/
RUN Scripts/build-release

FROM swift:${SWIFTVERSION}-${UBUNTUDISTRO}-slim AS runner

# Install Curl, add-apt-repository and node package repository
RUN apt-get update && apt-get install -y curl software-properties-common && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Install native dependencies
COPY Scripts/install-runtime-dependencies-apt Scripts/
RUN Scripts/install-runtime-dependencies-apt && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/d2

# Install Node dependencies
COPY Scripts/install-node-dependencies Scripts/
COPY Node Node
RUN Scripts/install-node-dependencies

# Add resources
COPY Resources Resources
COPY LICENSE README.md ./

ARG TARGETOS
ARG TARGETARCH

# Set up .build folder in runner
WORKDIR /opt/d2/.build
COPY Scripts/setup-dotbuild-tree Scripts/
RUN Scripts/setup-dotbuild-tree

# Copy font used by swiftplot to the correct path
COPY --from=builder \
    "/opt/d2/.build/checkouts/swiftplot/Sources/AGGRenderer/CPPAGGRenderer/Roboto-Regular.ttf" \
                   "checkouts/swiftplot/Sources/AGGRenderer/CPPAGGRenderer/Roboto-Regular.ttf"

# Copy syllable counter resource bundle to the correct path
COPY --from=builder \
    "/opt/d2/.build/release/syllable-counter-swift_SyllableCounter.resources" \
                   "release/syllable-counter-swift_SyllableCounter.resources"

# Copy D2 executable
COPY --from=builder "/opt/d2/.build/release/D2" "release/D2"

WORKDIR /opt/d2
CMD [".build/release/D2"]
