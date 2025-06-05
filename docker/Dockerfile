# Dockerfile with intentional misconfigurations for Trivy testing

# Using latest tag - not recommended for production
FROM ubuntu:latest

# Running as root user throughout the build - security issue
USER root

# Installing packages without cleaning cache - increases image size
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    sudo \
    openssh-server \
    telnet \
    && apt-get install -y --no-install-recommends python3 python3-pip
    # No apt-get clean or rm -rf /var/lib/apt/lists/*

# Hardcoded secrets in environment variables - major security issue
ENV DATABASE_PASSWORD=password123
ENV API_KEY=sk-1234567890abcdef
ENV SECRET_TOKEN=abc123xyz789
ENV ADMIN_PASSWORD=admin123

# Setting unsafe permissions
RUN chmod 777 /tmp
RUN chmod 755 /etc/passwd

# Adding user with sudo privileges and weak password
RUN useradd -m -s /bin/bash appuser && \
    echo "appuser:password" | chpasswd && \
    usermod -aG sudo appuser

# Copying files with broad permissions
COPY . /app
RUN chmod -R 777 /app

# Installing packages from untrusted sources
RUN curl -sSL https://get.docker.com/ | sh
RUN wget -O - https://some-untrusted-site.com/install.sh | bash

# Exposing unnecessary ports
EXPOSE 22    # SSH
EXPOSE 23    # Telnet
EXPOSE 80    # HTTP
EXPOSE 443   # HTTPS
EXPOSE 3306  # MySQL
EXPOSE 5432  # PostgreSQL

# Creating files with sensitive information
RUN echo "admin:$1$salt$hash" > /etc/shadow.backup
RUN echo "database_password=secret123" > /app/config.txt
RUN echo "-----BEGIN PRIVATE KEY-----" > /app/private_key.pem
RUN echo "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC..." >> /app/private_key.pem

# Installing development tools in production image
RUN apt-get install -y \
    gcc \
    make \
    build-essential \
    gdb \
    strace

# Adding insecure configurations
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

# Working directory with broad permissions
WORKDIR /app
RUN chmod 777 /app

# Installing Python packages without pinning versions
RUN pip3 install \
    flask \
    requests \
    sqlalchemy \
    django \
    pillow

# Downloading and executing scripts from internet without verification
RUN curl -o /tmp/script.sh http://example.com/script.sh && \
    chmod +x /tmp/script.sh && \
    /tmp/script.sh

# Still running as root - container will run with root privileges
# USER root  # This should be changed to a non-root user

# Healthcheck with exposed credentials
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://admin:password123@localhost:80/health || exit 1

# Command that runs as root
CMD ["/bin/bash", "-c", "service ssh start && python3 /app/app.py"]
