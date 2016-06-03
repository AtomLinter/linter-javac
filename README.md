# linter-javac

This package will lint your opened `.java`-files on save, using [javac][javac-docs].


## Latest Changes

- 1.9.4 - Hotfixes exception after empty stderr-output (see [issue 96][iss96]).
- 1.9.2|3 - Fixes faulty handling of symbolic links in the files path (see [issue 94][iss94]).
- 1.9.1 - Hotfixes a bug introduced by 1.9.0.
- 1.9.0 - Adds generic support for localized javac output, supports chinese (see [issue 36][iss36]).

### Planned Milestones

- 2.0.0 - Complete rewrite of linter-javac (see [issue 76][iss76]).


## Installation

Ensure a working JDK is available in your environment (see FAQ) then enter the following on your command line:

    apm install linter-javac

Or Atom ➔ Preferences... ➔ Packages ➔ Search for "linter-javac".


## Settings

You can configure linter-javac by using the GUI (recommended - the GUI offers a description and valid defaults) or by editing your `~/.atom/config.cson` (or Atom ➔ Open Your Config):

```coffeescript

"linter-javac":
  javaExecutablePath: "javac"
  additionalClasspaths: "C:\Users\JohnDoe"
  additionalJavacOptions: "-verbose -d C:\java-class-cache"
  classpathFilename: ".acme-inc-classpaths"
  javacArgsFilename: "acme-inc-argfile"

```
Example-Configuration, see our [Wiki][wiki] or the config-GUI for further information.

> To configure linter-javac on a per project-base, we currently encourage you using the [project-manager package][project-manager].


## Classpath

> The currently implemented `.classpath`-file format conflicts with the Eclipse-based file format. Therefore this implementation will be replaced in the far future.  
We are aware that configuring classpath-information is the most important (and annoying) issue in linting source-files right - we are working hard to make our planned improvement imperceptible for you. We will keep you informed.

~~It is strongly recommended that you~~ You may configure your classpath via a so called classpath-file which by default is named `.classpath` (you can change the filename in the Atom-preferences).

The linter starts searching for your classpath-file in the directory where the source file resides which get's linted. If there is no matching classpath-file the search is continued wandering the file-tree up, until a classpath-file is found or the project-folder would be left.

You may place any directories classpath-file, delimited by your platform-specific path-dlimiter (`:`/`;`):

```java
.:./lib/junit.jar
```

A linter configured by the above example will execute `javac` in the directory where the classpath-file resides, so that relative paths will be resolved in dependency to the classpath-file-position.


## Frequently Asked Questions & Troubleshooting

Please take a look into our [FAQs at our wiki][faqs].

### Can I help?

Yes please! Give us feedback, file bugs or just help us coding - join us on https://github.com/AtomLinter/linter-javac/issues and leave a note!


:gift_heart:



[iss96]: https://github.com/AtomLinter/linter-javac/issues/96
[iss94]: https://github.com/AtomLinter/linter-javac/issues/94
[iss36]: https://github.com/AtomLinter/linter-javac/issues/36
[iss76]: https://github.com/AtomLinter/linter-javac/issues/76
[javac-docs]: https://docs.oracle.com/javase/8/docs/technotes/tools/unix/javac.html
[wiki]: https://github.com/AtomLinter/linter-javac/wiki
[project-manager]: https://atom.io/packages/project-manager
[faqs]: https://github.com/AtomLinter/linter-javac/wiki#frequently-asked-questions
