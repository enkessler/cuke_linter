# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
 - New linters
   - BackgroundDoesMoreThanSetupLinter
   - FeatureWithoutDescriptionLinter
   - SingleTestBackgroundLinter
   - StepWithEndPeriodLinter
   
## [0.4.0] - 2019-05-11

### Added
 - A base linter class has been added that can be used to create custom linters more easily by providing common boilerplate code that every linter would need.

### Changed
 - Linters now return only a single problem instead of returning a collection of problems.

## [0.3.1] - 2019-04-13

### Added
 - Now declaring required Ruby version. It's always been 2.x but now the gem actually says it officially.

## [0.3.0] - 2019-04-07

### Added
 - Linter configuration: linters can now be configured (turned on/off, conditions changed, etc.) instead of having to always use the default settings

## [0.2.0] - 2019-03-19

### Added
 - New linters
   - ExampleWithoutNameLinter
   - OutlineWithSingleExampleRowLinter
   - TestWithTooManyStepsLinter


## [0.1.0] - 2019-02-10

### Added
- Custom linters, formatters, and command line usability


[Unreleased]: https://github.com/enkessler/cuke_linter/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/enkessler/cuke_linter/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/enkessler/cuke_linter/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/enkessler/cuke_linter/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/enkessler/cuke_linter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/enkessler/cuke_linter/compare/2bbd3f29f4eb45b6e9ea7d47c5bb47182bf4fde7...v0.1.0
