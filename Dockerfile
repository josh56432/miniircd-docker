FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /irc

RUN pip install --no-cache-dir miniircd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6667
EXPOSE 6697

CMD ["/entrypoint.sh"]
