ARG SWIFTVERSION=5.7.2
ARG UBUNTUDISTRO=focal

FROM --platform=$BUILDPLATFORM swift:${SWIFTVERSION}-${UBUNTUDISTRO} AS builder

ARG SWIFTVERSION
ARG UBUNTUDISTRO
ARG BUILDARCH
ARG TARGETARCH

ARG CROSSCOMPILESYSROOT=/usr/${TARGETARCH}-ubuntu-${UBUNTUDISTRO}

# Install native dependencies or (if cross-compiling) set up sysroot
COPY Scripts/install-build-dependencies-apt Scripts/install-cross-compilation-sysroot Scripts/
RUN if [ "$BUILDARCH" = "$TARGETARCH" ]; then Scripts/install-build-dependencies-apt && rm -rf /var/lib/apt/lists/*; else Scripts/install-cross-compilation-sysroot; fi

# Build
WORKDIR /opt/d2
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.resolved ./
COPY Scripts/build-release Scripts/
RUN Scripts/build-release

FROM swift:${SWIFTVERSION}-${UBUNTUDISTRO}-slim AS runner

# Install Curl, add-apt-repository and node package repository
RUN apt-get update && apt-get install -y curl software-properties-common && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

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
