# syntax=docker/dockerfile:1
#FROM ubuntu:rolling as builder
#RUN apt update -y
#RUN apt install git cargo -y
#RUN git clone https://git.sr.ht/~laalsaas/pbkdf2-password-hash
#WORKDIR /pbkdf2-password-hash
#RUN cargo build

FROM python

ARG TARGET
ARG ENTRY
ENV TARGET=${TARGET} ENTRY=${ENTRY}

RUN pip install "$TARGET"

ENV SYNC_BASE=/data PASSWORDS_HASHED=1

VOLUME ["/data"]

CMD ["sh", "-c", "python -m $TARGET.$ENTRY"]
