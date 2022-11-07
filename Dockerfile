FROM swift:5.7 as builder

# Install add-apt-repository
RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:alex-p/tesseract-ocr && apt-get update && apt-get install -y \
    libssl-dev \
    libfreetype6-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libgraphviz-dev \
    libtesseract-dev \
    libleptonica-dev \
    && rm -rf /var/lib/apt/lists/*

# Build
WORKDIR /opt/d2
COPY Sources Sources
COPY Tests Tests
COPY Package.swift Package.resolved ./
RUN swift build -c release

FROM swift:5.7-slim as runner

# Install Curl, add-apt-repository and node package repository
RUN apt-get update && apt-get install -y curl software-properties-common && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Install native dependencies
RUN add-apt-repository -y ppa:alex-p/tesseract-ocr && apt-get update && apt-get install -y \
    libssl1.1 \
    libfreetype6 \
    libcairo2 \
    libsqlite3-0 \
    tesseract-ocr \
    poppler-utils \
    maxima \
    graphviz \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/d2

# Install Node dependencies
COPY Node Node
RUN cd Node && ./install-all

# Add resources
COPY Resources Resources
COPY LICENSE README.md ./

# Set up .build folder in runner
WORKDIR /opt/d2/.build
RUN mkdir -p x86_64-unknown-linux-gnu/release && ln -s x86_64-unknown-linux-gnu/release release

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
