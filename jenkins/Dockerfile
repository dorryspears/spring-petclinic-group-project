FROM jenkins/jenkins:lts

# Switch to root to install packages
USER root

# Add Node.js repository and install packages
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    sshpass \
    ansible \
    docker.io \
    nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    usermod -aG docker jenkins

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-arm64
ENV PATH $JAVA_HOME/bin:$PATH

# Switch back to jenkins user
USER jenkins 