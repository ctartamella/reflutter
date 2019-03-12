# Changelog

## 0.6.0

- Simplified the API by removing the ```ReflutterResponse``` object.  Methods now only need
    return ```Future<T>``` or ```Future<List<T>>```.

## 0.5.2

- Fixed a bug where null or undefined query parameters were included in query strings.

## 0.5.1

- Reintroduced request/response interceptors
- Cleaned up output code.

## 0.5.0

- Updated typing and some other code quality issues.
- Increased support for query parameters
- Support for optional parameters.
- Updated packages and serialization support.

## 0.3.0

- Reorganized into three separate packages.  ```reflutter``` will serve as the main
    dependency while ```refluter_generator``` can be a dev dependency.
- Removed the dependency on the Jaguar project for serialization.  Instead,
    we opt for the more standard Dart JSON serialization.
- Test infrastructure and some very simple unit tests have been added.
- Travis build infrastructure updated.

## 0.2.4

- Fixed [Issue 1](https://github.com/ctartamella/reflutter/issues/1)

## 0.2.3

- Build change to cache items between phases.

## 0.2.2

- Initial release with a changelog.
