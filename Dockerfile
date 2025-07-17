FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y curl software-properties-common gnupg2 ca-certificates lsb-release

# Add WineHQ repository
RUN mkdir -pm755 /etc/apt/keyrings && \
    curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/winehq-archive-keyring.gpg] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/winehq.list

# Add multiverse (for SteamCMD)
RUN add-apt-repository multiverse && apt update

# Install Wine + SteamCMD
RUN apt install -y --install-recommends \
        winehq-stable \
        steamcmd \
        winetricks \
        xvfb \
        cabextract \
        unzip

# Install Windows version of SteamCMD (into wine prefix) as it may be needed to get around some mod loading issues
USER se
WORKDIR /home/se
RUN mkdir -p /home/se/win-steamcmd && \
    curl -Lo steamcmd.zip https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip && \
    unzip steamcmd.zip -d /home/se/win-steamcmd && \
    rm steamcmd.zip && \
    wine /home/se/win-steamcmd/steamcmd.exe +quit

# Add user and set up wine prefix
RUN adduser se --disabled-password --gecos "" && \
    mkdir -p /wineprefix && \
    chown -R se:se /wineprefix

# Copy winetricks and setup scripts
COPY install-winetricks /scripts/
COPY entrypoint.bash /entrypoint.bash
COPY entrypoint-space_engineers.bash /entrypoint-space_engineers.bash
RUN chmod +x /scripts/install-winetricks /entrypoint.bash /entrypoint-space_engineers.bash && \
    chown se /entrypoint-space_engineers.bash

USER se
WORKDIR /scripts
RUN bash ./install-winetricks

# Final setup
USER root
RUN mkdir -p /appdata/space-engineers/bin /appdata/space-engineers/config

CMD ["/entrypoint.bash"]
