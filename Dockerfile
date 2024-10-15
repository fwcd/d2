ARG SWIFTVERSION=6.0
ARG UBUNTUDISTRO=jammy

FROM swift:${SWIFTVERSION}-${UBUNTUDISTRO} AS builder

ARG SWIFTVERSION
ARG UBUNTUDISTRO

WORKDIR /opt/d2

# Install dependencies
COPY Scripts/install-build-dependencies-apt Scripts/
RUN Scripts/install-build-dependencies-apt

# (Cross-)compile D2
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.resolved ./
COPY Scripts/build-release Scripts/
RUN Scripts/build-release

FROM swift:${SWIFTVERSION}-${UBUNTUDISTRO}-slim AS runner

WORKDIR /opt/d2

# Install build essentials (for node-gyb), curl and node
RUN apt-get update && apt-get install -y build-essential curl software-properties-common && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Install native dependencies
COPY Scripts/install-runtime-dependencies-apt Scripts/
RUN Scripts/install-runtime-dependencies-apt && rm -rf /var/lib/apt/lists/*

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
COPY Scripts/prepare-docker-dotbuild Scripts/standard-arch-name Scripts/
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
ENTRYPOINT [".build/release/D2"]
