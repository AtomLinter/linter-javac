# linter-javac

This package will lint your opened `.java`-files on save, using [javac](javac-docs).

## Installation

Ensure a working JDK is available in your environment (see FAQ) then enter the following on your command line:

    apm install linter-javac

Or Atom ➔ Preferences... ➔ Packages ➔ Search for "linter-javac".

## Settings

You can configure linter-javac by using the GUI (recommended - the GUI offers a description and validation of the settings) or by editing your `~/.atom/config.cson` (or Atom ➔ Open Your Config):

```coffeescript
"linter-javac":
  javaExecutablePath: "javac"
  additionalClasspaths: "C:\Users\JohnDoe"
  additionalJavacOptions: "-verbose -d C:\java-class-cache"
```
Example-Configuration, see our [Wiki](wiki) or the config-GUI for further information.

> To configure linter-javac on a per project-base, we currently encourage you using the [project-manager package](project-manager).

## Classpath

> The currently implemented `.classpath`-file format conflicts with the Eclipse-based file format. Therefore this implementation will be replaced in the far future.  
We are aware that configuring classpath-information is the most important (and annoying) issue in linting source-files right - we are working hard to make our planned improvement imperceptible for you. We will keep you informed.

~It is strongly recommended that you~ You may configure your classpath via a `.classpath` file within your project (typically at the root). Simply create a file named `.classpath` somewhere within your project (ideally at the root of the project). The linter will search for this file by starting at the directory of the file being compiled and then searching all parent directories within the project. If you have more than one of these configuration files, it will use the one that is "closest" to the file being compiled. Within `.classpath` place only the classpath to be used for the project (nothing else). For example:

```java
.:./lib/junit.jar
```

This linter will execute `javac` within the directory of the `.classpath`
file, so relative paths can be considered to be relative to that file.

## Frequently Asked Questions

Please take a look into our [[FAQs at our wiki]](faqs).

### Can I help?

Yes please! Give us feedback, file bugs or just help us coding - join us on https://github.com/AtomLinter/linter-javac/issues and leave a note!


:heart_gift:



[javac-docs]: https://docs.oracle.com/javase/8/docs/technotes/tools/unix/javac.html
[Wiki]: https://github.com/AtomLinter/linter-javac/wiki
[project-manager]: https://atom.io/packages/project-manager
[faqs]: https://github.com/AtomLinter/linter-javac/wiki#frequently-asked-questions
