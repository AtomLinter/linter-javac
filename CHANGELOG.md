# Change Log

## [1.5.0](https://github.com/AtomLinter/linter-javac/tree/1.5.0) (2016-01-11)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v1.4.0...1.5.0)

**Implemented enhancements:**

- Synchronously walking file system [\#44](https://github.com/AtomLinter/linter-javac/issues/44)
- Force EOL to be LF [\#52](https://github.com/AtomLinter/linter-javac/pull/52) ([Arcanemagus](https://github.com/Arcanemagus))
- Asynchronously walk paths [\#45](https://github.com/AtomLinter/linter-javac/pull/45) ([noseglid](https://github.com/noseglid))

**Merged pull requests:**

- atom-linter@4.3.1 untested ⚠️ [\#53](https://github.com/AtomLinter/linter-javac/pull/53) ([greenkeeperio-bot](https://github.com/greenkeeperio-bot))
- atom-linter@4.3.0 untested ⚠️ [\#51](https://github.com/AtomLinter/linter-javac/pull/51) ([greenkeeperio-bot](https://github.com/greenkeeperio-bot))
- atom-package-deps@3.0.7 untested ⚠️ [\#50](https://github.com/AtomLinter/linter-javac/pull/50) ([greenkeeperio-bot](https://github.com/greenkeeperio-bot))

## [v1.4.0](https://github.com/AtomLinter/linter-javac/tree/v1.4.0) (2015-12-30)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v1.3.0...v1.4.0)

**Implemented enhancements:**

- Derive current project root from active file [\#43](https://github.com/AtomLinter/linter-javac/pull/43) ([noseglid](https://github.com/noseglid))
- Only lint files in .classpath directory [\#40](https://github.com/AtomLinter/linter-javac/pull/40) ([ilikebits](https://github.com/ilikebits))

**Closed issues:**

- Only lints if it is the first of multiple open project roots [\#42](https://github.com/AtomLinter/linter-javac/issues/42)
- "Duplicate class" error [\#39](https://github.com/AtomLinter/linter-javac/issues/39)
- Uncaught TypeError: undefined is not a function [\#7](https://github.com/AtomLinter/linter-javac/issues/7)

**Merged pull requests:**

- atom-linter@4.2.0 untested ⚠️ [\#49](https://github.com/AtomLinter/linter-javac/pull/49) ([greenkeeperio-bot](https://github.com/greenkeeperio-bot))
- Update all dependencies 🌴 [\#48](https://github.com/AtomLinter/linter-javac/pull/48) ([Arcanemagus](https://github.com/Arcanemagus))

## [v1.3.0](https://github.com/AtomLinter/linter-javac/tree/v1.3.0) (2015-11-04)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Allow daw42 to be maintainer of this package. [\#33](https://github.com/AtomLinter/linter-javac/issues/33)

**Fixed bugs:**

- fixes \#31. send all java files in the project to javac, so it has the… [\#32](https://github.com/AtomLinter/linter-javac/pull/32) ([m4tty](https://github.com/m4tty))

**Closed issues:**

- Maven Java Project [\#21](https://github.com/AtomLinter/linter-javac/issues/21)
- Linting occurs, but the results of linting don't display [\#12](https://github.com/AtomLinter/linter-javac/issues/12)
- Can not make javac linter work [\#4](https://github.com/AtomLinter/linter-javac/issues/4)

## [v1.2.0](https://github.com/AtomLinter/linter-javac/tree/v1.2.0) (2015-09-06)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v1.1.0...v1.2.0)

**Closed issues:**

- In packages with multiple files, only the current file is sent to javac. Errors are reported if dependencies exist.. [\#31](https://github.com/AtomLinter/linter-javac/issues/31)

## [v1.1.0](https://github.com/AtomLinter/linter-javac/tree/v1.1.0) (2015-08-11)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v1.0.1...v1.1.0)

**Implemented enhancements:**

- Support classpath configuration via .classpath files. [\#30](https://github.com/AtomLinter/linter-javac/pull/30) ([daw42](https://github.com/daw42))
- Support configurable classpath [\#27](https://github.com/AtomLinter/linter-javac/pull/27) ([daw42](https://github.com/daw42))
- Load environment variable CLASSPATH [\#26](https://github.com/AtomLinter/linter-javac/pull/26) ([pleonex](https://github.com/pleonex))

**Closed issues:**

- Too much errors [\#29](https://github.com/AtomLinter/linter-javac/issues/29)
- Make classpath configurable [\#25](https://github.com/AtomLinter/linter-javac/issues/25)
- Configuration of javaExecutablePath is missing [\#6](https://github.com/AtomLinter/linter-javac/issues/6)

## [v1.0.1](https://github.com/AtomLinter/linter-javac/tree/v1.0.1) (2015-08-05)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v1.0.0...v1.0.1)

**Implemented enhancements:**

- Upcoming linter changes [\#20](https://github.com/AtomLinter/linter-javac/issues/20)

**Fixed bugs:**

- External classes aren't resolved correctly and therefore show up as errors [\#1](https://github.com/AtomLinter/linter-javac/issues/1)

**Closed issues:**

- Regex is getting incorrect results in some cases [\#28](https://github.com/AtomLinter/linter-javac/issues/28)

## [v1.0.0](https://github.com/AtomLinter/linter-javac/tree/v1.0.0) (2015-08-03)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v0.1.4...v1.0.0)

**Implemented enhancements:**

- Port to linter-plus [\#23](https://github.com/AtomLinter/linter-javac/pull/23) ([daw42](https://github.com/daw42))

**Closed issues:**

- LinterJavac.Linter is deprecated. [\#24](https://github.com/AtomLinter/linter-javac/issues/24)
- Object.activate is deprecated. [\#22](https://github.com/AtomLinter/linter-javac/issues/22)

## [v0.1.4](https://github.com/AtomLinter/linter-javac/tree/v0.1.4) (2015-05-22)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v0.1.3...v0.1.4)

**Fixed bugs:**

- Repaired 2 deprecation cop errors per \#14 [\#15](https://github.com/AtomLinter/linter-javac/pull/15) ([skylineproject](https://github.com/skylineproject))

**Closed issues:**

- Package.getActivationCommands is deprecated. [\#19](https://github.com/AtomLinter/linter-javac/issues/19)
- Package.activateConfig is deprecated. [\#18](https://github.com/AtomLinter/linter-javac/issues/18)
- Config.unobserve is deprecated. [\#17](https://github.com/AtomLinter/linter-javac/issues/17)
- Package.activateConfig is deprecated. [\#16](https://github.com/AtomLinter/linter-javac/issues/16)
- 2 deprecations warnings with current API [\#14](https://github.com/AtomLinter/linter-javac/issues/14)
- Typo on readme [\#10](https://github.com/AtomLinter/linter-javac/issues/10)
- linter-javac complains about regular UTF8 characters [\#9](https://github.com/AtomLinter/linter-javac/issues/9)

## [v0.1.3](https://github.com/AtomLinter/linter-javac/tree/v0.1.3) (2014-08-10)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v0.1.2...v0.1.3)

**Fixed bugs:**

- Fixed broke regex string [\#8](https://github.com/AtomLinter/linter-javac/pull/8) ([glek](https://github.com/glek))

**Closed issues:**

- File Name - Class Name match problem [\#5](https://github.com/AtomLinter/linter-javac/issues/5)

## [v0.1.2](https://github.com/AtomLinter/linter-javac/tree/v0.1.2) (2014-06-02)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v0.1.1...v0.1.2)

## [v0.1.1](https://github.com/AtomLinter/linter-javac/tree/v0.1.1) (2014-05-17)
[Full Changelog](https://github.com/AtomLinter/linter-javac/compare/v0.1.0...v0.1.1)

**Closed issues:**

- linter-javac catches no warnings [\#3](https://github.com/AtomLinter/linter-javac/issues/3)

## [v0.1.0](https://github.com/AtomLinter/linter-javac/tree/v0.1.0) (2014-05-17)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*