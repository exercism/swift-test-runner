FROM swift:6.1.0 AS builder
# WORKDIR /opt/testrunner

COPY Package.swift ./Package.swift

RUN swift build

COPY src/testrunner ./

# Print Installed Swift Version
RUN swift --version
#RUN swift package clean
RUN swift build --configuration release

FROM swift:6.1.0
RUN apt-get update && apt-get install -y jq
WORKDIR /opt/test-runner/
COPY bin/ bin/
COPY --from=builder .build/repositories/ /root/.cache/org.swift.swiftpm/repositories/
COPY --from=builder .build/repositories/ .build/repositories/
COPY --from=builder /.build/release/TestRunner bin/

ENV NAME RUNALL

ENTRYPOINT ["./bin/run.sh"]
