# Stage 1: Precompile TestRunner and Module Cache
FROM swift:6.1.2 AS builder
RUN swift --version

# Build TestRunner executable
WORKDIR /TestRunner
COPY src/TestRunner .
RUN swift build --configuration release

# Build WarmUp package
# Build directory and final working paths should be equal for reuse of ModuleCache.
# /solution is mounting point where exercise package is added.
WORKDIR /solution
COPY src/WarmUp .
RUN swift build --build-tests

# Stage 2: Prepare docker container image
FROM swift:6.1.2
RUN apt-get update && apt-get install -y jq

WORKDIR /opt/test-runner/
COPY bin/run.sh bin/run.sh
COPY --from=builder /TestRunner/.build/release/TestRunner bin/
COPY --from=builder /solution/.build .build
COPY --from=builder /solution/Package.resolved Package.resolved

ENV RUNALL=

ENTRYPOINT ["./bin/run.sh"]
