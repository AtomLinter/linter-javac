# linter-javac

This package will lint your `.java` opened files in Atom through [javac](http://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html).

This package will ensure all dependencies are installed on activation.

## Installation

* Install [java](http://www.java.com/).
* `$ apm install linter-javac`

## Settings
You can configure linter-javac by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):

    'linter-javac':
      # The path to javac.   The default (javac) should work as long as you have it
      # in your system PATH.
      'javaExecutablePath': "javac"
      # Extra classpath.  This will be appended to the classpath when executing javac.
      'classpath': ''

## Classpath

It is strongly recommended that you configure your classpath via a `.classpath`
file within your project (typically at the root).  Simply create a file
named `.classpath` somewhere within your project (ideally at the root of
the project).  The linter will search
for this file by starting at the directory of the file being compiled and then
searching all parent directories within the project.  If you have more than one
of these configuration files, it will use the one that is "closest" to the file
being compiled.  Within `.classpath` place only the classpath to be used for the
project (nothing else).  For example:

    .:./lib/junit.jar

This linter will execute `javac` within the directory of the `.classpath`
file, so relative paths can be considered to be relative to that file.

## Other available linters
There are other linters available - take a look at the linters [mainpage](https://github.com/AtomLinter/Linter).
