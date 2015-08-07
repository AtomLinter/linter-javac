# linter-javac

This package will lint your `.java` opened files in Atom through [javac](http://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html).

## Installation

* Install [java](http://www.java.com/).
* `$ apm install linter` (if you don't have [AtomLinter/Linter](https://github.com/AtomLinter/Linter) installed).
* `$ apm install linter-javac`

## Settings
You can configure linter-javac by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):

    'linter-javac':
      # The path to javac.   The default (javac) should work as long as you have it
      # in your system PATH.
      'javaExecutablePath': "javac"
      # Extra classpath.  This will be appended to the classpath when executing javac.
      'classpath': ''

You can also configure the classpath on a per-project basis.  Simply create a file
named `.linter-javac.cson` somewhere within your project (ideally at the root of
the project).  The linter will search
for this file by starting at the directory of the file being compiled and then
searching all parent directories within the project.  If you have more than one
of these configuration files, it will use the one that is "closest" to the file
being compiled.  Within `.linter-javac.cson` you can configure the classpath.  
For example:

    classpath: ".:./lib/junit.jar"

This linter will execute `javac` within the directory of the `.linter-javac.cson`
file, so relative paths can be considered to be relative to that `.cson`
file.

## Other available linters
There are other linters available - take a look at the linters [mainpage](https://github.com/AtomLinter/Linter).
