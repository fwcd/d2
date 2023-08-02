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

ARG TARGETSYSROOT=/usr/local/${TARGETARCH}-ubuntu-${UBUNTUDISTRO}

WORKDIR /opt/d2

# Copy target sysroot into builder
# TODO: Only copy stuff that we need for compilation (/usr/lib, /usr/include etc.)
COPY --from=sysroot / ${TARGETSYSROOT}

# Install (cross-)GCC and patch some paths
COPY Scripts/prepare-docker-buildroot Scripts/get-linux-arch-name Scripts/
RUN Scripts/prepare-docker-buildroot

# (Cross-)compile D2
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.resolved ./
COPY Scripts/build-release Scripts/
RUN Scripts/build-release

FROM swift:${SWIFTVERSION}-${UBUNTUDISTRO}-slim AS runner

ARG TARGETARCH
ARG UBUNTUDISTRO

ARG TARGETSYSROOT=/usr/local/${TARGETARCH}-ubuntu-${UBUNTUDISTRO}

# Install Curl, add-apt-repository and node package repository
RUN apt-get update && apt-get install -y curl software-properties-common && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Install native dependencies
COPY Scripts/install-runtime-dependencies-apt Scripts/
RUN Scripts/install-runtime-dependencies-apt && rm -rf /var/lib/apt/lists/*

# Link 'sysroot' to / to make sure D2 can find the Swift stdlibs
# (the runpath within the D2 executable still points to its /usr/lib/swift)
RUN ln -s / ${TARGETSYSROOT}

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
COPY Scripts/prepare-docker-dotbuild Scripts/get-linux-arch-name Scripts/
RUN Scripts/prepare-docker-dotbuild

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
