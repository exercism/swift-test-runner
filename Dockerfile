FROM swift:6.1.2 AS builder
# WORKDIR /opt/testrunner

COPY src/TestRunner ./

# Print Installed Swift Version
RUN swift --version
#RUN swift package clean
RUN swift build --configuration release

FROM swift:6.1.2
RUN apt-get update && apt-get install -y jq
WORKDIR /opt/test-runner/
COPY bin/ bin/

COPY Package.swift ./Package.swift

RUN swift build

COPY --from=builder /.build/release/TestRunner bin/

ENV NAME RUNALL

ENTRYPOINT ["./bin/run.sh"]
