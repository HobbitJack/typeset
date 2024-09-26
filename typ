#!/usr/bin/python
# typeset text nicely for paginating

# This program takes in a prose text file where each line is a paragraph.
# It then outputs a modified text file. This new text file is modified as follows:
# 1) Each line is limited to a certain number of characters, breaking on spaces only
# 2) Every line is given a margin
# 2) Only the first line of each paragraph is indented
# 3) Lines in all caps are centered
# 4) Lines starting with # are removed
# 5) Lines starting with // are not indented or centered
# 6) Empty lines can be kept or stripped
# 7) Paragraphs are double-spaced, lines can be too
# Note each line is treated independently.
import getopt
import stat
import os
import sys
import string

AFTER_PERIOD_SPACES = 1
PAGE_WIDTH = 84
TARGET_WIDTH = 0
TAB_WIDTH = 8
MARGIN_WIDTH = 0

CENTER_CHAPTERS = True
DOUBLE_SPACE_PARAGRAPHS = False
DOUBLE_SPACE_LINES = False
STRIP_EMPTY = True
INDENT_LINES = True

short_options = "cdDM:st:Tw:W:hv"
long_options = [
    "no-center-chapters",
    "double-space-paragraphs",
    "double-space-lines",
    "margin-width=",
    "no-strip-empty-lines",
    "tab-width=",
    "no-indent-lines",
    "page-width=",
    "target-width=",
    "help",
    "version",
]

try:
    options, positional_arguments = getopt.gnu_getopt(
        sys.argv[1:], short_options, long_options
    )
except getopt.GetoptError as error:
    print(f"typ: '-{error.opt}': Option not recognized")
    sys.exit(1)

for option in options:
    argument = option[1]
    option = option[0]

    if option == "-h" or option == "--help":
        print("Usage: typ [OPTION]... [FILE]")
        print(
            "Typeset paragraph text nicely for paginating with your paginator of choice"
        )
        sys.exit(0)
    elif option == "-v" or option == "--version":
        print("typ v1.0.1")
        sys.exit(0)
    elif option == "-C" or option == "--no-center-chapters":
        CENTER_CHAPTERS = False
    elif option == "-d" or option == "--double-space-paragraphs":
        DOUBLE_SPACE_PARAGRAPHS = True
    elif option == "-D" or option == "--double-space-lines":
        DOUBLE_SPACE_LINES = True
    elif option == "-M" or option == "--margin-width":
        try:
            MARGIN_WIDTH = int(argument)
            if MARGIN_WIDTH < 0:
                raise ValueError
        except ValueError:
            print(f"typ: '{MARGIN_WIDTH}': Invalid margin width")
            sys.exit(1)
    elif option == "-s" or option == "--no-strip-empty-lines":
        STRIP_EMPTY = False
    elif option == "-t" or option == "--tab-width":
        try:
            TAB_WIDTH = int(argument)
            if TAB_WIDTH < 0:
                raise ValueError
            elif TAB_WIDTH == 0:
                INDENT_LINES = False
        except ValueError:
            print(f"typ: '{TAB_WIDTH}': Invalid tab width")
            sys.exit(1)
    elif option == "-T" or option == "--no-indent-lines":
        INDENT_LINES = False
    elif option == "-w" or option == "--page-width":
        try:
            PAGE_WIDTH = int(argument)
            if PAGE_WIDTH < 8:
                raise ValueError
        except ValueError:
            print(f"typ: '{PAGE_WIDTH}': Invalid page width")
            sys.exit(1)
    elif option == "-W" or option == "--target-width":
        try:
            TARGET_WIDTH = int(argument)
            if TARGET_WIDTH < 4:
                raise ValueError
        except ValueError:
            print(f"typ: '{argument}': Invalid target width")
            sys.exit(1)

if not TARGET_WIDTH:
    if PAGE_WIDTH < 40:
        TARGET_WIDTH = int(round(PAGE_WIDTH * 0.83, 0))
    else:
        TARGET_WIDTH = int(round(PAGE_WIDTH * 0.90, 0))

TAB_WIDTH = TAB_WIDTH * INDENT_LINES + MARGIN_WIDTH

if MARGIN_WIDTH > PAGE_WIDTH:
    print(f"typ: Margin width cannot be greater than page width")
    sys.exit(1)

if TAB_WIDTH > PAGE_WIDTH:
    print(f"typ: Tab width cannot be greater than page width")
    sys.exit(1)

if TARGET_WIDTH > PAGE_WIDTH:
    print(f"typ: Target width cannot be greater than page width")
    sys.exit(1)

PAGE_WIDTH = PAGE_WIDTH - MARGIN_WIDTH

if not positional_arguments:
    if stat.S_ISFIFO(os.fstat(0).st_mode):
        input_file = "-"
    else:
        print("typ: Missing operand")
        sys.exit(1)
else:
    if len(positional_arguments) > 1:
        print("typ: Too many arguments")
        sys.exit(1)
    else:
        input_file = positional_arguments[0]

if input_file == "-":
    all_lines = sys.stdin.read().splitlines()
else:
    if os.path.isfile(input_file):
        pass
    elif os.path.isfile(f"{os.getcwd}/{input_file}"):
        input_file = f"{os.getcwd}/{input_file}"
    elif os.path.isdir(input_file) or os.path.isdir(f"{os.getcwd}/{input_file}"):
        print(f"typ: {input_file}: Is a directory")
        sys.exit(1)
    else:
        print(f"typ: {input_file}: No such file or directory")
        sys.exit(1)

    with open(input_file, mode="r", encoding="utf8") as text_file:
        all_lines = text_file.read().splitlines()

last_line_note = False
last_line_centered = False
header_centered = False
for line in all_lines:
    line = line.strip()

    # Skip lines starting with #
    if line.startswith("#"):
        continue

    # Strip blank lines
    if STRIP_EMPTY and line == "":
        continue

    # Center lines in all caps
    if (
        CENTER_CHAPTERS
        and line == line.upper()
        and any(char in string.ascii_uppercase for char in line)
        and not line.startswith("//")
    ):
        if last_line_centered:
            header_centered = True
        last_line_centered = True
        if len(line) + MARGIN_WIDTH <= PAGE_WIDTH:
            center_room = PAGE_WIDTH - len(line) - MARGIN_WIDTH
            spacing = center_room // 2
            line = f"{' '*(spacing + MARGIN_WIDTH)}{line}"
            print(line)
        elif len(line) <= PAGE_WIDTH:
            center_room = PAGE_WIDTH - len(line)
            spacing = center_room // 2
            line = f"{' '*(spacing)}{line}"
            print(line)
        else:
            words = line.split(" ")
            line = " " * (MARGIN_WIDTH - 1)
            for word in words:
                if len(word) > PAGE_WIDTH:
                    for character in word:
                        if len(line) < PAGE_WIDTH:
                            line = f"{line}{character}"
                            continue
                        else:
                            first_line = False
                            print(line)
                            if DOUBLE_SPACE_LINES:
                                print()
                            line = f"{' ' * MARGIN_WIDTH}{character}"
                            continue
                elif len(line) + len(word) + 1 > PAGE_WIDTH:
                    center_room = PAGE_WIDTH - len(line)
                    spacing = center_room // 2
                    line = f"{' '*(spacing)}{line}"
                    print(line)
                    line = f"{' ' * MARGIN_WIDTH} {word}"
                else:
                    line = f"{line} {word}"
            if line:
                center_room = PAGE_WIDTH - len(line)
                spacing = center_room // 2
                line = f"{' '*(spacing)}{line}"
                print(line)

    else:
        first_line = True
        if header_centered:
            print()
        last_line_centered = False
        header_centered = False

        # Indent lines by spaces (use unexpand(1) if this is a problem)
        words = line.split(" ")

        line = (
            " " * TAB_WIDTH
            if INDENT_LINES and not line.startswith("//")
            else " " * MARGIN_WIDTH
        )
        if words[0].startswith("//"):
            last_line_note = True
            words[0] = words[0][2:]
            first_line = False
        else:
            if last_line_note:
                last_line_note = False
                print()
        for word in words:
            word = word.strip()

            if len(line) > TARGET_WIDTH:
                first_line = False
                print(line)
                if DOUBLE_SPACE_LINES:
                    print()
                line = " " * MARGIN_WIDTH

            if (
                len(line) + len(word) + 1  # For the space between the words
                > PAGE_WIDTH
            ):
                if len(word) > PAGE_WIDTH:
                    for character in word:
                        if len(line) < PAGE_WIDTH:
                            line = f"{line}{character}"
                            continue
                        else:
                            first_line = False
                            print(line)
                            if DOUBLE_SPACE_LINES:
                                print()
                            line = f"{' ' * MARGIN_WIDTH}{character}"
                            continue
                else:
                    first_line = False
                    print(line)
                    if DOUBLE_SPACE_LINES:
                        print()
                    line = f"{' ' * MARGIN_WIDTH}{word}"
                    continue
            else:
                line = f"{line}{' ' if line.strip() else ''}{word}"

        print(line)
        if DOUBLE_SPACE_PARAGRAPHS and not last_line_note:
            print()
            if DOUBLE_SPACE_LINES:
                print()
