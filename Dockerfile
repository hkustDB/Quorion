FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

# Base tools + Python + PostgreSQL client
# Removed python3-zstandard from apt as it is not in 20.04 repos
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip tar zstd \
    git build-essential pkg-config libreadline-dev jq openssl less vim \
    python3 python3-pip python3-venv \
    postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# Java 1.8 (Temurin), Scala 2.12.10, Maven 3.8.6
RUN mkdir -p /opt/java /opt/scala /opt/maven && \
  curl -L -o /tmp/jdk8.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u442-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u442b06.tar.gz && \
  tar -xzf /tmp/jdk8.tar.gz -C /opt/java && rm /tmp/jdk8.tar.gz && \
  curl -L -o /tmp/scala.tgz https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz && \
  tar -xzf /tmp/scala.tgz -C /opt/scala && rm /tmp/scala.tgz && \
  curl -L -o /tmp/maven.tgz https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
  tar -xzf /tmp/maven.tgz -C /opt/maven && rm /tmp/maven.tgz

ENV JAVA_HOME=/opt/java/jdk8u442-b06
ENV SCALA_HOME=/opt/scala/scala-2.12.10
ENV MAVEN_HOME=/opt/maven/apache-maven-3.8.6
ENV PATH=$JAVA_HOME/bin:$SCALA_HOME/bin:$MAVEN_HOME/bin:$PATH

# Python packages
# Ubuntu 20.04 pip is older and does not require --break-system-packages
# Added zstandard here
RUN python3 -m pip install --no-cache-dir docopt requests flask openpyxl pandas matplotlib numpy argparse pyarrow zstandard

# Build TPC-H dbgen
WORKDIR /tpch-dbgen
RUN git clone https://github.com/electrum/tpch-dbgen.git . && \
    make clean && make

# Remove non-root user creation and switch
# RUN useradd -m -u 1000 appuser
# USER# filepath: /home/data/bchenba/Quorion/Dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

# Base tools + Python + PostgreSQL client
# Removed python3-zstandard from apt as it is not in 20.04 repos
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip tar zstd \
    git build-essential pkg-config libreadline-dev jq openssl less vim \
    python3 python3-pip python3-venv \
    postgresql-client openssh-client\
    zlib1g-dev libicu-dev \
  && rm -rf /var/lib/apt/lists/*

# Java 1.8 (Temurin), Scala 2.12.10, Maven 3.8.6
RUN mkdir -p /opt/java /opt/scala /opt/maven && \
  curl -L -o /tmp/jdk8.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u442-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u442b06.tar.gz && \
  tar -xzf /tmp/jdk8.tar.gz -C /opt/java && rm /tmp/jdk8.tar.gz && \
  curl -L -o /tmp/scala.tgz https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz && \
  tar -xzf /tmp/scala.tgz -C /opt/scala && rm /tmp/scala.tgz && \
  curl -L -o /tmp/maven.tgz https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
  tar -xzf /tmp/maven.tgz -C /opt/maven && rm /tmp/maven.tgz

ENV JAVA_HOME=/opt/java/jdk8u442-b06
ENV SCALA_HOME=/opt/scala/scala-2.12.10
ENV MAVEN_HOME=/opt/maven/apache-maven-3.8.6
ENV PATH=$JAVA_HOME/bin:$SCALA_HOME/bin:$MAVEN_HOME/bin:$PATH

# Python packages
# Ubuntu 20.04 pip is older and does not require --break-system-packages
# Added zstandard here
RUN python3 -m pip install --no-cache-dir docopt requests flask openpyxl pandas matplotlib numpy argparse pyarrow zstandard

# Build TPC-H dbgen
WORKDIR /tpch-dbgen
RUN git clone https://github.com/electrum/tpch-dbgen.git . && \
    make clean && make

# Remove non-root user creation and switch
# RUN useradd -m -u 1000 appuser
# USER appuser
WORKDIR /Quorion

CMD ["/bin/bash"]