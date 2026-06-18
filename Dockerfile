# syntax=docker/dockerfile:1
#FROM ubuntu:rolling as builder
#RUN apt update -y
#RUN apt install git cargo -y
#RUN git clone https://git.sr.ht/~laalsaas/pbkdf2-password-hash
#WORKDIR /pbkdf2-password-hash
#RUN cargo build

FROM python
RUN pip install anki
ENV SYNC_BASE=/data PASSWORDS_HASHED=1
VOLUME ["/data"]
#COPY --from=0 /pbkdf2-password-hash/target/debug/pbkdf2-hash-password /opt/pbkdf2-hash-password
CMD python -m anki.syncserver
