# Initialize
FROM python:3

# Install
WORKDIR /app/data
RUN apt-get update
#RUN apt-get install --yes \
#		net-tools 
RUN pip install --no-cache-dir \ 
		discord
RUN git clone https://github.com/EnriqueMoran/remoteDiscordShell.git

# Run-time
ENTRYPOINT [ "python3", "pyDiscordShellBot.py" ]