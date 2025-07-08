FROM swift:6.1.2 AS test-runner-builder

WORKDIR /build
COPY src/TestRunner ./
RUN swift --version && swift build --configuration release


FROM swift:6.1.2 AS dependencies-builder

WORKDIR /build
COPY Package.swift ./Package.swift
RUN swift build


FROM debian:12

WORKDIR /opt
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
   # Test runner
   jq \
   # Swift requirements from https://www.swift.org/install/linux/tarball/
   binutils-gold \
   gcc \
   git \
   libcurl4-openssl-dev \
   libedit-dev \
   libicu-dev \
   libncurses-dev \
   libpython3-dev \
   libsqlite3-dev \
   libxml2-dev \
   pkg-config \
   tzdata \
   uuid-dev \
   # Packages to downlaod Swift
   wget ca-certificates \
   # Packages to verify (GPG)
   gpg dirmngr gpg-agent \
 && rm -rf /var/lib/apt/lists/* \
 # https://download.swift.org/swift-6.1.2-release/debian12/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE-debian12.tar.gz
 && wget https://download.swift.org/swift-6.1.2-release/debian12/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE-debian12.tar.gz \
 && wget https://download.swift.org/swift-6.1.2-release/debian12/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE-debian12.tar.gz.sig \
 # "Swift 6.x Release Signing Key" from https://www.swift.org/keys/active/
 && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys '52BB 7E3D E28A 71BE 22EC 05FF EF80 A866 B47A 981F' \
 && gpg --verify swift-6.1.2-RELEASE-debian12.tar.gz.sig \
 # Unpack the tarball
 && tar xf swift-6.1.2-RELEASE-debian12.tar.gz \
 && mv swift-6.1.2-RELEASE-debian12/usr/ swift/ \
 # Cleanup image (apt packages, downloaded files)
 && apt-get purge -y wget ca-certificates gpg dirmngr gpg-agent \
 && apt-get autoremove -y --purge \
 && rm swift-6.1.2-RELEASE-debian12.tar.gz swift-6.1.2-RELEASE-debian12.tar.gz.sig

ENV PATH="$PATH:/opt/swift/bin"
WORKDIR /opt/test-runner/
COPY bin/ bin/
COPY --from=test-runner-builder /build/.build/release/TestRunner bin/
COPY --from=dependencies-builder /build /opt/test-runner

ENV NAME=RUNALL

ENTRYPOINT ["./bin/run.sh"]
