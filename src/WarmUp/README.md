# Swift build cache warm-up for faster builds inside docker
## Overview

Cold swift builds are slow. We need fast feedback — to respond quickly when someone runs an exercise and not hit Docker timeouts. This package is used to build warm-up: it prebuilds the .build folder during docker image creation.

## Why cold builds are slow?

When Swift compiles from a clean state, it spends a huge amount of time on resolving dependencies. Imports like Foundation, Numerics, Dispatch, etc. pull in a ton of underlying clang and swift modules like SwiftShims, SwiftGlibc, _Builtin_stddef, etc.

Even if you don’t import them directly, Swift still needs to find, parse, and compile some of them into .build and specifically ModuleCache directory.

## What does this package do?

It simply imports all the common libraries that exercises usually rely on:

```swift
import Foundation
import Numerics
import _Concurrency
```

Then it gets built during Docker image creation. So when a student runs their solution later all the dependencies are already ready.