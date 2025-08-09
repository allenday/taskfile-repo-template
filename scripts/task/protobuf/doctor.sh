#!/bin/bash

set -euo pipefail

echo "⚡ PROTOCOL BUFFERS DEVELOPMENT ENVIRONMENT HEALTH CHECK"
echo "======================================================="
echo ""

# Check if Protobuf project exists
PROTOBUF_PROJECT=false
if [ -d "proto" ] || find . -maxdepth 2 -name "*.proto" | head -1 | grep -q .; then
    PROTOBUF_PROJECT=true
fi

if [ "$PROTOBUF_PROJECT" = false ]; then
    echo "ℹ️  No Protocol Buffers project detected - skipping protobuf health checks"
    echo "   Looked for: proto/ directory or *.proto files"
    exit 0
fi

echo "🔍 Protocol Buffers Project Detected"
echo ""

# Check Protocol Buffers tools
echo "🛠️  Protocol Buffers Tools:"
ISSUES=0

if command -v protoc >/dev/null 2>&1; then
    PROTOC_VERSION=$(protoc --version | cut -d' ' -f2)
    echo "✅ Protocol Compiler (protoc): $PROTOC_VERSION"
    
    # Check protoc version compatibility
    PROTOC_MAJOR=$(echo "$PROTOC_VERSION" | cut -d. -f1)
    PROTOC_MINOR=$(echo "$PROTOC_VERSION" | cut -d. -f2)
    
    if [ "$PROTOC_MAJOR" -ge 3 ] && [ "$PROTOC_MINOR" -ge 12 ]; then
        echo "✅ Protoc Version: Modern (>= 3.12)"
    elif [ "$PROTOC_MAJOR" -ge 3 ]; then
        echo "⚠️  Protoc Version: Older but supported (3.x)"
    else
        echo "❌ Protoc Version: Too old (< 3.0)"
        ISSUES=$((ISSUES + 1))
    fi
else
    echo "❌ Protocol Compiler (protoc): Not installed"
    echo "   Install: brew install protobuf"
    ISSUES=$((ISSUES + 1))
fi

if command -v buf >/dev/null 2>&1; then
    BUF_VERSION=$(buf --version | cut -d' ' -f2)
    echo "✅ Buf: $BUF_VERSION (modern protobuf tooling)"
else
    echo "⚠️  Buf: Not installed (recommended for modern workflows)"
    echo "   Install: brew install bufbuild/buf/buf"
fi

echo ""

# Check project structure
echo "📁 Project Structure:"
if [ -d "proto" ]; then
    PROTO_COUNT=$(find proto -name "*.proto" | wc -l | tr -d ' ')
    echo "✅ Proto Directory: Found with $PROTO_COUNT .proto files"
    
    # Check for common protobuf patterns
    if find proto -name "*.proto" -exec grep -l "syntax.*proto3" {} \; | wc -l | grep -q -v "^0$"; then
        echo "✅ Proto Syntax: Using proto3 (recommended)"
    elif find proto -name "*.proto" -exec grep -l "syntax.*proto2" {} \; | wc -l | grep -q -v "^0$"; then
        echo "⚠️  Proto Syntax: Using proto2 (consider upgrading to proto3)"
    else
        echo "⚠️  Proto Syntax: No explicit syntax declared"
    fi
    
    # Check for package declarations
    if find proto -name "*.proto" -exec grep -l "package " {} \; | wc -l | grep -q -v "^0$"; then
        echo "✅ Proto Packages: Using package declarations"
    else
        echo "⚠️  Proto Packages: No package declarations found"
    fi
else
    PROTO_COUNT=$(find . -maxdepth 2 -name "*.proto" | wc -l | tr -d ' ')
    echo "⚠️  Proto Directory: Not found, but $PROTO_COUNT .proto files exist"
    echo "   Consider organizing .proto files in a proto/ directory"
fi

echo ""

# Check configuration files
echo "⚙️  Configuration Files:"
if [ -f "buf.yaml" ] || [ -f "buf.yml" ]; then
    echo "✅ Buf Configuration: Found"
    
    # Check buf configuration validity
    if command -v buf >/dev/null 2>&1; then
        if buf config ls-files >/dev/null 2>&1; then
            echo "✅ Buf Config: Valid syntax"
        else
            echo "❌ Buf Config: Invalid syntax"
            ISSUES=$((ISSUES + 1))
        fi
    fi
else
    echo "⚠️  Buf Configuration: Not found"
    echo "   Consider adding buf.yaml for modern protobuf tooling"
fi

if [ -f "buf.gen.yaml" ] || [ -f "buf.gen.yml" ]; then
    echo "✅ Buf Generation Config: Found"
else
    echo "⚠️  Buf Generation Config: Not found"
    echo "   Consider adding buf.gen.yaml for code generation"
fi

if [ -f "buf.work.yaml" ] || [ -f "buf.work.yml" ]; then
    echo "✅ Buf Workspace: Configured"
else
    echo "⚠️  Buf Workspace: Not configured (may be intentional)"
fi

echo ""

# Check generated code directories
echo "🏗️  Generated Code:"
LANGS_FOUND=0

for lang in go java python cpp typescript javascript csharp; do
    case $lang in
        go)
            if [ -d "gen/go" ] || [ -d "generated/go" ] || find . -path "*/pb/*.pb.go" | head -1 | grep -q .; then
                echo "✅ Go: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
        java)
            if [ -d "gen/java" ] || [ -d "generated/java" ] || find . -name "*.pb.java" | head -1 | grep -q .; then
                echo "✅ Java: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
        python)
            if [ -d "gen/python" ] || [ -d "generated/python" ] || find . -name "*_pb2.py" | head -1 | grep -q .; then
                echo "✅ Python: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
        cpp)
            if [ -d "gen/cpp" ] || [ -d "generated/cpp" ] || find . -name "*.pb.h" -o -name "*.pb.cc" | head -1 | grep -q .; then
                echo "✅ C++: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
        typescript)
            if [ -d "gen/typescript" ] || [ -d "generated/typescript" ] || find . -name "*.pb.ts" | head -1 | grep -q .; then
                echo "✅ TypeScript: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
        javascript)
            if [ -d "gen/javascript" ] || [ -d "generated/javascript" ] || find . -name "*_pb.js" | head -1 | grep -q .; then
                echo "✅ JavaScript: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
        csharp)
            if [ -d "gen/csharp" ] || [ -d "generated/csharp" ] || find . -name "*.pb.cs" | head -1 | grep -q .; then
                echo "✅ C#: Generated code found"
                LANGS_FOUND=$((LANGS_FOUND + 1))
            fi
            ;;
    esac
done

if [ $LANGS_FOUND -eq 0 ]; then
    echo "⚠️  No generated code found"
    echo "   Run code generation with: task protobuf:gen-all"
else
    echo "   Total languages with generated code: $LANGS_FOUND"
fi

echo ""

# Check for gRPC services
echo "🌐 gRPC Services:"
if find proto -name "*.proto" -exec grep -l "service " {} \; 2>/dev/null | wc -l | grep -q -v "^0$"; then
    SERVICE_COUNT=$(find proto -name "*.proto" -exec grep -l "service " {} \; 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ gRPC Services: $SERVICE_COUNT service(s) defined"
    
    # Check for gRPC tools if services are present
    if command -v grpc_cli >/dev/null 2>&1; then
        echo "✅ gRPC CLI: Available for testing services"
    else
        echo "⚠️  gRPC CLI: Not available (useful for service testing)"
    fi
else
    echo "⚠️  gRPC Services: No services defined"
    echo "   This is normal for message-only proto files"
fi

echo ""

# Check build tools and dependencies
echo "🔧 Language-Specific Tools:"
LANG_TOOLS=0

# Go protobuf tools
if command -v protoc-gen-go >/dev/null 2>&1; then
    echo "✅ Go: protoc-gen-go installed"
    LANG_TOOLS=$((LANG_TOOLS + 1))
fi

if command -v protoc-gen-go-grpc >/dev/null 2>&1; then
    echo "✅ Go gRPC: protoc-gen-go-grpc installed"
    LANG_TOOLS=$((LANG_TOOLS + 1))
fi

# Python protobuf tools
if command -v python3 >/dev/null 2>&1 && python3 -c "import grpc_tools" >/dev/null 2>&1; then
    echo "✅ Python: grpcio-tools available"
    LANG_TOOLS=$((LANG_TOOLS + 1))
fi

if [ $LANG_TOOLS -eq 0 ]; then
    echo "⚠️  No language-specific protobuf tools detected"
    echo "   Install tools for your target languages"
fi

echo ""

# Linting and validation
echo "🔍 Linting and Validation:"
if command -v buf >/dev/null 2>&1 && [ -f "buf.yaml" ] || [ -f "buf.yml" ]; then
    if buf lint >/dev/null 2>&1; then
        echo "✅ Buf Lint: All proto files pass linting"
    else
        echo "⚠️  Buf Lint: Some issues found"
        echo "   Run: buf lint"
    fi
    
    if buf format --diff --exit-code >/dev/null 2>&1; then
        echo "✅ Buf Format: All proto files are properly formatted"
    else
        echo "⚠️  Buf Format: Some files need formatting"
        echo "   Run: buf format --write"
    fi
else
    echo "⚠️  Buf Lint/Format: Cannot check (buf not available or not configured)"
fi

echo ""

# Summary
echo "🎯 Summary:"
if [ $ISSUES -eq 0 ]; then
    echo "✅ Protocol Buffers development environment health check passed"
    if [ $LANGS_FOUND -ge 1 ] && command -v buf >/dev/null 2>&1; then
        echo "   Environment is well-configured for protobuf development"
    else
        echo "   Consider setting up code generation and buf tooling for better workflow"
    fi
else
    echo "❌ $ISSUES critical issues found - see above for resolution steps"
    echo "   Fix these issues to ensure proper protobuf development environment"
    exit 1
fi