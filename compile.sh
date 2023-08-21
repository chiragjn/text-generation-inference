#!/bin/bash

set -eoux

export PATH=/usr/local/cargo/bin:$PATH
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
export TGI_HOME=/root/text-generation-inference

PROTOC_ZIP=protoc-21.12-linux-x86_64.zip && \
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v21.12/$PROTOC_ZIP && \
unzip -o $PROTOC_ZIP -d /usr/local bin/protoc && \
unzip -o $PROTOC_ZIP -d /usr/local 'include/*' && \
rm -f $PROTOC_ZIP


mkdir -p $TGI_HOME/tgi1/ $TGI_HOME/tgi2/
cp -fr Cargo.toml rust-toolchain.toml proto benchmark router launcher $TGI_HOME/tgi1/
cd $TGI_HOME/tgi1/
cargo chef prepare --recipe-path recipe.json

cd /root/text-generation-inference
cp $TGI_HOME/tgi1/recipe.json $TGI_HOME/tgi2/recipe.json
cd $TGI_HOME/tgi2/
cargo chef cook --release --recipe-path recipe.json

cd /root/text-generation-inference
cp -r Cargo.toml rust-toolchain.toml proto benchmark router launcher $TGI_HOME/tgi2/
cd $TGI_HOME/tgi2/
cargo build --release