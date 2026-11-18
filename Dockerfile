ARG REPO=exercism/swift-docker-base
ARG IMAGE=latest

# Stage 1: Precompile TestRunner
FROM ${REPO}:${IMAGE} AS builder
RUN swift --version

# Build TestRunner executable
WORKDIR /TestRunner
COPY src/TestRunner .
RUN swift build --configuration release --build-system native

# Stage 2: Prepare docker container image
FROM ${REPO}:${IMAGE} AS base
# bin/fast-test.sh links with mold, which takes about 0.15 seconds for a test
# binary where GNU ld takes 0.35 seconds.
RUN apt-get update && apt-get install -y jq mold

WORKDIR /opt/test-runner

# Build TestEnvironment package
# Build directory and final working paths should be equal for reuse of ModuleCache.
COPY src/TestEnvironment .
RUN swift build --build-tests --build-system native

COPY bin/run.sh bin/run-test.sh bin/fast-test.sh bin/
COPY src/FastTest src/FastTest
RUN bin/fast-test.sh --prepare /opt/test-runner
COPY --from=builder /TestRunner/.build/release/TestRunner bin/

ENV RUN_IN_DOCKER=TRUE

ENTRYPOINT ["./bin/run.sh"]
