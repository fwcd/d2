FROM swift:5.1

# Install Curl and node package repository
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# TODO: Workaround for https://bugs.swift.org/browse/SR-10344
# (see also https://forums.swift.org/t/lldb-install-precludes-installing-python-in-image/24040)
RUN mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages; ln -s dist-packages /usr/lib/python2.7/site-packages

# Install native dependencie
RUN apt-get update && apt-get install -y \
    nodejs \
    libopus-dev \
    libsodium-dev \
    libssl1.0-dev \
    libcairo2-dev \
    poppler-utils \
    maxima

# Copy application
WORKDIR /d2/app
COPY . .

# Install Node dependencies
WORKDIR /d2/app/Node
RUN ./install-all

# Build
WORKDIR /d2/app
RUN swift build

CMD ["./build/debug/D2"]
