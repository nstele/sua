Sua Swift
---------

Sua Swift is a project to experiment with Swift on Ubuntu/Linux.

Swift has recently been released as open source and is supported on Ubuntu. But
it seems as though that the main APIs are still too heavily dependent on OSX,
even if there are signs that they may be reimplementing many of the APIs on
Swift itself and they may be more portable then.

While Swift may come with standard libraries, the fact that Swift has great
support for calling C libraries directly means that it is easy to experiment
with new libraries and APIs for Swift. The combination of Swift + Linux will
be explored for many years to come and it may give rise to many such libraries,
until a major project based on them takes over the scene.

With Sua Swift, I start on that path for leaner APIs for Swift. The examples
that I come up with may help to document Swift further, if anything.

Sua is a Portuguese word that means "yours". Sua Swift means "your Swift". It
also is a play on how both words are pronounced, both beginning with about the
same sound. Sua also resembles another programming word in Portuguese that is
well known, "Lua" of the Lua programming language fame.

Given how short the Sua word is, it could also be used as a prefix in some words
to help to avoid name conflicts with more standard APIs.

License
-------

Same as Swift's.

Progress Notes
--------------

As of December 11, 2015, Sua has been coming along nicely. There is now a
dependency on an external sister project called CSua that is an extremely
small library at the moment, helping only to map the variadic open Linux
function: https://github.com/jpedrosa/csua_module

I tried to keep it to as few repositories as possible, while taking the package
manager's necessary requirements into consideration. To help to make the names
unique, I gave the CSua project an extended name of csua_module. The CSua is
made up of a csua.c, csua.h, CMakeLists.txt, Package.swift and module.modulemap
files only. CMake helps to build it and install the files into /usr/local for
system-wide reference by the package manager. The problem for now with external
module dependencies is that we have to keep importing them into the project
files in order to help the linker with the needed libraries. One of the examples
now has code like this:

```swift
import Glibc
import Sua
import CSua
```

Imagine it if there were more libraries involved! I'm not complaining too much,
since in other languages we also have to import code all the time. It is just
that Swift is still rough on the edges and getting past the errors that we as
end-users help to cause can be quite daunting. One of the differences with low
level languages is that the errors can be quite opaque! Scary, in other words.
Even more so to those of us used to higher level languages. But we also get used
to it as we go. Power comes with great responsibility, as they say.

If you wanted to create your own modules and are unsure about how to get the
needed files in order, I suggest you take a look at all the Package.swift files
these projects have scattered around. You can even search on GitHub for more
examples.

When I'm developing Sua, one trick I use to speed the process up is that I use a
custom main.swift to produce an executable based on the libraries. But I don't
need to commit it to GitHub. So that the changes I keep making to it don't
pollute the repository too much. I find it better than to depend on the library
from other projects. I really don't like it when the package manager gets in the
way of quicker turnaround, so finding ways around it can be more than helpful,
while we give the time for the Swift tools to mature for open source needs.

I also use the Atom editor for Swift too. It's quite handy!
