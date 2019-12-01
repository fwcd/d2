FROM swift:5.1

# Install native dependencies
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get-install -y \
    nodejs \
    libopus-dev \
    libsodium-dev \
    libssl1.0-dev \
    libcairo2-dev \
    poppler-utils \
    maxima

# Copy application
WORKDIR /app
COPY . .

# Install Node dependencies
WORKDIR /app/Node
RUN ./install-all

# Build
RUN swift build

CMD ["./build/debug/D2"]
