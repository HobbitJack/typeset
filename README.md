# typset
A very simple Unix pipeline-based typesetting package.

As of version v1.0.0, ``typset`` consists of three tools.
All included tools are designed around working with plain text, and a very small and trivial to learn typesetting language applies to help get certain types of special formatting out.
Note that these tools are designed around the way *I* write plain-text documents, as stories and such for my Creative Writing class, and occassionaly as write-ups for other classes. As such, this formatting style may not be what you need.
The three special types of text are as follows.

First are SECTION TITLES. SECTION TITLES are in all caps and come on their own lines. These will stay on their own lines, and will be centered once typesetting is applied.

Next are //notes. //notes are lines that start with //C-style comments. Notes are treated as document text, but will not have special formatting like line joining or indenting applied. I use these to make reader's notes stand apart from body text.

Lastly are #comments. #comments are lines that belong in the source document but which are not wanted in the final document -- perhaps some notes about characters, or maybe your thoughts while writing the section. These will be removed by ``typ`` and so will not make it into a final document typeset with the ``typset`` pipeline.

## ``lj`` -- line join
``lj``, or line join, joins lines of text where each line is assumed to be a sentence on its own line.

The following example demonstrates the use of ``lj``. Consider Example.txt included in this repository.
```
$ cat Example.txt
THIS IS THE TITLE OF THIS DOCUMENT
//This is a note about the nature of this document
This is a sentence.
This is also a sentence!
Is this a third sentence?
It is!
And this is even a fifth sentence!
Wow! That's so cool!

THIS IS A NEW SECTION
#This is a comment so I can remember where I got some information from
This is a new paragraph.
This is another line in the document! Wow!
"This is a quote from my favorite source!"
This is the last line in the document.
Oops, there's one more.
```
Applying ``lj`` with no flags produces:
```
$ lj Example.txt
THIS IS THE TITLE OF THIS DOCUMENT
//This is a note about the nature of this document
This is a sentence. This is also a sentence! Is this a third sentence? It is! And this is even a fifth sentence! Wow! That's so cool!

THIS IS A NEW SECTION
#This is a comment so I can remember where I got some information from
This is a new paragraph. This is another line in the document! Wow!
"This is a quote from my favorite source!"
This is the last line in the document. Oops, there's one more.
```
Notice how the quotaton is set off in its own line -- that is, its own paragraph. This is because this program is designed for typesetting short stories, where quotations are speech and so should be set off as paragraphs.
The behavior of this program can be modified with program flags. For example, to treat quotations as a part of the document (for example, in typesetting an argumentative essay), you can pass -q to disable this behavior and treat them as sentences of their own.
The newline is kept for consistency as depending on what you do with this text, you may want to keep newlines as they are. For example, however, ``typ``, the next program in the package, strips these and adds its own.

## ``typ`` -- typeset text
``typ``, or typeset, typesets lines of text where each line is a paragraph with multiple sentences.

This example demonstrates the use of ``typ``, here applied to the above output from ``lj`` on Example.txt included with this repository.
Note a shorter line length has been chosen to better show the line-wrapping capability. Defaults is a line width of 84.
```
$ lj Example.txt | typ -w40
   THIS IS THE TITLE OF THIS DOCUMENT
This is a note about the nature of this
document

        This is a sentence. This is also
a sentence! Is this a third sentence?
It is! And this is even a fifth
sentence! Wow! That's so cool!
         THIS IS A NEW SECTION
        This is a new paragraph. This
is another line in the document! Wow!
        "This is a quote from my
favorite source!"
        This is the last line in the
document. Oops, there's one more.
```
For shorter text, the line length target is roughly 83% of the total line length. For longer lines, where it's less jagged to go to a newline, a target width of 93% is used instead.
This isn't perfect but as you can see above it doesn't do that bad.
Some flags can also be used to disable centering notes and stripping empty lines, if you wish to keep those in the output.

## pag -- paginate text
``pag``, or paginate, paginates text and adds headers to pages. Headers are not used if the page is too short -- less than 10 lines. 

This example demonstrates the use of ``pag`` on the output of the above ``typ`` example, using Example.txt included with this repository.
As before, a maximum page length and width different from the defaults of 66 and 84 respectively.
```
$ lj Example.txt | typ -w40 | pag -L10 -w40

9/16/2024                         Page 1

   THIS IS THE TITLE OF THIS DOCUMENT
This is a note about the nature of this
document

        This is a sentence. This is also
a sentence! Is this a third sentence?
^L

9/16/2024                         Page 2

It is! And this is even a fifth
sentence! Wow! That's so cool!
         THIS IS A NEW SECTION
        This is a new paragraph. This
is another line in the document! Wow!
        "This is a quote from my
^L

9/16/2024                         Page 3

favorite source!"
        This is the last line in the
document. Oops, there's one more.
```
Linefeeds have been modified for this example to show as ^L.
Some users may wish to typeset the header using MLA mode, which reads in 4 comments at the start of the document and a 5th line with a section header, and will use the last name from the name provided to typeset the page headers.
The title of the document will also then be corrected to title case from all caps.
## typset -- pipeline typesetting text
typeset is a meta-script to typeset a document straight from the first form. Certain flags are ignored and this is primarily a convience wrapper for certain settings commonly used when typesetting the documents I work with.
All you need to do is set the page width and length, and you get nice output like below:
```
$ typset -L10 -w40  Example.txt

    9/16/2024                 Page 1

 THIS IS THE TITLE OF THIS DOCUMENT
    This is a note about the nature
    of this document

        This is a sentence. This is
    also a sentence! Is this a third
^L

    9/16/2024                 Page 2

    sentence? It is! And this is
    even a fifth sentence! Wow!
    That's so cool!
         THIS IS A NEW SECTION
        This is a new paragraph.
    This is another line in the
^L

    9/16/2024                 Page 3

    document! Wow!
        "This is a quote from my
    favorite source!"
        This is the last line in the
    document. Oops, there's one
    more.
```
Notice how this also includes a margin. Again, linefeeds have been modified for visibility.
# Documentation
Right now, no. Soon, the help messages for each program will be filled out beyond usage, and man pages (don't get your hopes up, probably using ``help2man`` if we're being honest) will be written.
# Bugs
Please file a GitHub issue if you find any bugs or crashes. Alternatively, I'll fix them as I find them.
# License
``typset`` is licenesed under the GNU GPLv3.0. See LICENSE for a full list of terms.
Copyright (C) HobbitJack 2024
