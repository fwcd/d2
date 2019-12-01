FROM swift:5.1

# Install native dependencies
# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
# RUN apt-get update && apt-get-install -y \
#     nodejs \
#     libopus-dev \
#     libsodium-dev \
#     libssl1.0-dev \
#     libcairo2-dev \
#     poppler-utils \
#     maxima

# # Copy application
# WORKDIR /d2/app
# COPY . .

# # Install Node dependencies
# WORKDIR /d2/app/Node
# RUN ./install-all

# # Build
# WORKDIR /d2/app
# RUN swift build

# CMD ["./build/debug/D2"]
WORKDIR /app
COPY envvars-to-files .
CMD ["./envvars-to-files"]
