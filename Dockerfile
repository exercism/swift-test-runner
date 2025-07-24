# Stage 1: Precompile TestRunner and Module Cache
FROM swift:6.1.2 AS builder
RUN swift --version

# Build TestRunner executable
WORKDIR /TestRunner
COPY src/TestRunner .
RUN swift build --configuration release

# Build ModuleCache from WarpUm package
WORKDIR /WarmUp
COPY src/WarmUp .
RUN swift build \
    --build-tests \
    -Xswiftc -module-cache-path -Xswiftc /opt/test-runner/.modulecache

# Stage 2: Prepare docker container image
FROM swift:6.1.2
RUN apt-get update && apt-get install -y jq

WORKDIR /opt/test-runner/
COPY bin/run.sh bin/run.sh
COPY --from=builder /TestRunner/.build/release/TestRunner bin/
COPY --from=builder /WarmUp/.build .build
COPY --from=builder /WarmUp/Package.resolved Package.resolved
COPY --from=builder /opt/test-runner/.modulecache .modulecache/

ENV NAME RUNALL

ENTRYPOINT ["./bin/run.sh"]
