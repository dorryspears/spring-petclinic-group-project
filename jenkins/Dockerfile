FROM jenkins/jenkins:lts

# Switch to root to install packages
USER root

# Install necessary packages including Java 17
RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    sshpass \
    ansible && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-arm64
ENV PATH $JAVA_HOME/bin:$PATH

# Switch back to jenkins user
USER jenkins 