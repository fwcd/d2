FROM swift:5.4 as builder

# Install add-apt-repository
RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:alex-p/tesseract-ocr && apt-get update && apt-get install -y \
    libssl-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libgraphviz-dev \
    libtesseract-dev \
    libleptonica-dev \
    && rm -rf /var/lib/apt/lists/*

# Build
WORKDIR /opt/d2
COPY . .
RUN swift build -c release

FROM swift:5.4-slim as runner

# Install Curl, add-apt-repository and node package repository
RUN apt-get update && apt-get install -y curl software-properties-common && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Install native dependencies
RUN add-apt-repository -y ppa:alex-p/tesseract-ocr && apt-get update && apt-get install -y \
    libssl1.1 \
    libcairo2 \
    libsqlite3-0 \
    tesseract-ocr \
    poppler-utils \
    maxima \
    graphviz \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Node dependencies
COPY Node /opt/d2/Node
WORKDIR /opt/d2/Node
RUN ./install-all

WORKDIR /opt/d2/

# Add resources
COPY Resources Resources

COPY --from=builder "/opt/d2/.build/release/D2" .

CMD ["./D2"]
