FROM swift:5.3.3-bionic AS builder

COPY src/testrunner ./

RUN swift --version
RUN swift build --configuration release

FROM swift:5.3.3-bionic
WORKDIR /opt/test-runner/
COPY bin/ bin/
COPY --from=builder /.build/release/TestRunner bin/

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
