#!/bin/bash

set -euo pipefail

# Generate protobuf code for specified language
# Usage: generate-code.sh <language> <proto_dir> <output_dir>

LANGUAGE="${1:-}"
PROTO_DIR="${2:-proto}"
OUTPUT_DIR="${3:-generated}"

if [ -z "$LANGUAGE" ]; then
    echo "Usage: $0 <language> [proto_dir] [output_dir]"
    echo "Supported languages: go, python, typescript, java, cpp"
    exit 1
fi

generate_go() {
    find "$PROTO_DIR" -name "*.proto" -exec protoc \
        --go_out="$OUTPUT_DIR" \
        --go-grpc_out="$OUTPUT_DIR" \
        --proto_path="$PROTO_DIR" {} \;
    echo "Go protobuf code generated in $OUTPUT_DIR"
}

generate_python() {
    find "$PROTO_DIR" -name "*.proto" -exec protoc \
        --python_out="$OUTPUT_DIR" \
        --grpc_python_out="$OUTPUT_DIR" \
        --proto_path="$PROTO_DIR" {} \;
    echo "Python protobuf code generated in $OUTPUT_DIR"
}

generate_typescript() {
    find "$PROTO_DIR" -name "*.proto" -exec protoc \
        --plugin=protoc-gen-ts=./node_modules/.bin/protoc-gen-ts \
        --ts_out="$OUTPUT_DIR" \
        --proto_path="$PROTO_DIR" {} \;
    echo "TypeScript protobuf code generated in $OUTPUT_DIR"
}

generate_java() {
    find "$PROTO_DIR" -name "*.proto" -exec protoc \
        --java_out="$OUTPUT_DIR" \
        --proto_path="$PROTO_DIR" {} \;
    echo "Java protobuf code generated in $OUTPUT_DIR"
}

generate_cpp() {
    find "$PROTO_DIR" -name "*.proto" -exec protoc \
        --cpp_out="$OUTPUT_DIR" \
        --proto_path="$PROTO_DIR" {} \;
    echo "C++ protobuf code generated in $OUTPUT_DIR"
}

case "$LANGUAGE" in
    go)
        generate_go
        ;;
    python)
        generate_python
        ;;
    typescript)
        generate_typescript
        ;;
    java)
        generate_java
        ;;
    cpp)
        generate_cpp
        ;;
    *)
        echo "Unsupported language: $LANGUAGE"
        echo "Supported languages: go, python, typescript, java, cpp"
        exit 1
        ;;
esac