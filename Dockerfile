FROM rust:1.73.0-bookworm AS substrate

WORKDIR /substrate

EXPOSE 9944 30333 9933

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
		git \
		clang \
		curl \
		libssl-dev \
		protobuf-compiler \
	&& rm -rf /var/lib/apt/lists/*
RUN rustup toolchain install nightly-2023-10-20
RUN rustup default nightly-2023-10-20
RUN rustup target add wasm32-unknown-unknown --toolchain nightly-2023-10-20
# RUN rustup default stable
# RUN rustup update
# RUN rustup update nightly
# RUN rustup target add wasm32-unknown-unknown --toolchain nightly

# RUN apt-get update \
# 	&& apt upgrade -y \
# 	&& apt install -y curl \
# 	&& curl https://getsubstrate.io -sSf | bash -s -- --fast

# RUN curl https://sh.rustup.rs -sSf -y | sh

# ENV PATH="/root/.cargo/bin:${PATH}"

# RUN rustup toolchain install nightly

# RUN rustup default nightly

# RUN rustup target add wasm32-unknown-unknown --toolchain nightly

COPY . .

RUN WASM_BUILD_TOOLCHAIN=nightly-2023-10-20 cargo build --release

# CMD ./target/release/node-template --dev

# Only run for benchmarking
# RUN cd bin/node-template/node && WASM_BUILD_TOOLCHAIN=nightly-2020-09-27 cargo build --release --features runtime-benchmarks && cd ../../..

RUN mkdir /aquila-node && mkdir /aquila-node/target && mkdir /aquila-node/target/release

RUN cp -r target/release/node-template /aquila-node/target/release/node-template && cp -r config /aquila-node/config

# RUN cp -r target/release/substrate /aquila-node/target/release/substrate

# RUN cp -r target/release/node-bench /aquila-node/target/release/node-bench

RUN rm -r /substrate

FROM substrate AS aquila-node

RUN chmod +x /aquila-node/config/docker-run.sh

ENTRYPOINT ["/aquila-node/config/docker-run.sh"]

# CMD ["sh", "-c", "/aquila-node/target/release/node-template", \
# 	 "--base-path ","/tmp/validator_1 ", \
# 	 "--chain","/aquila-node/config/customSpecRaw.json", \
# 	 "--port","30333", \
# 	 "--rpc-port", "9944", \
# 	 "--rpc-cors","all", \
# 	 "--telemetry-url","wss://telemetry.polkadot.io/submit/ 0", \
# 	 "--validator", \
# 	 "--rpc-external", \
# 	 "--rpc-methods", "Unsafe", \
# 	 "--name", "node_validator" \
# 	]
# RUN nohup ./target/release/node-template \
#   --base-path /tmp/validator_1 \
#   --chain ./config/customSpecRaw.json \
#   --port 30333 \
#   --rpc-port 9944 \
#   --rpc-cors all \
#   --telemetry-url "wss://telemetry.polkadot.io/submit/ 0" \
#   --validator \
#   --rpc-external \
#   --rpc-methods Unsafe \
#   --name node_validator &


