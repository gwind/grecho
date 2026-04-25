FROM rust:1-bookworm AS builder
WORKDIR /app

#ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

#RUN mkdir -p /root/.cargo
#RUN echo '[source.crates-io]\nreplace-with = "rsproxy"\n\n[source.rsproxy]\nregistry = "sparse+https://rsproxy.cn/index/"' > /root/.cargo/config.toml

COPY Cargo.toml Cargo.lock* ./
COPY src ./src
COPY Settings.toml* ./

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

USER 10001:10001
COPY --from=builder /app/target/release/grecho /usr/local/bin/grecho

EXPOSE 8080

ENTRYPOINT ["grecho", "--hostname", "0.0.0.0", "--port", "8080"]
