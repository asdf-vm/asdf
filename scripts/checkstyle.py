#!/usr/bin/env python3
import re
import os
import argparse
from pathlib import Path
from typing import Callable, List, Dict, Any # compat

# This file checks Bash and Shell scripts for violations not found with
# shellcheck or existing methods. You can use it in several ways:
#
# Lint all .bash, .sh, and .bats files and print out violations
# $ ./scripts/checkstyle.py
#
# The former, but also fix all violations. This must be ran until there
# are zero violations since any line can have more than one violation
# $ ./scripts/checkstyle.py --fix
#
# Lint a particular file
# $ ./scripts/checkstyle.py ./lib/functions/installs.bash
#
# Check to ensure all regexes are working as intended
# $ ./scripts/checkstyle.py --internal-test-regex

Rule = Dict[str, Any]

class c:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    LINK: Callable[[str, str], str] = lambda href, text: f'\033]8;;{href}\a{text}\033]8;;\a'

def utilGetStrs(line, m):
    return (
        line[0:m.start('match')],
        line[m.start('match'):m.end('match')],
        line[m.end('match'):]
    )

# Before: printf '%s\\n' '^w^'
# After: printf '%s\n' '^w^'
def noDoubleBackslashFixer(line: str, m) -> str:
    prestr, midstr, poststr = utilGetStrs(line, m)

    return f'{prestr}{midstr[1:]}{poststr}'

# Before: $(pwd)
# After: $PWD
def noPwdCaptureFixer(line: str, m) -> str:
    prestr, midstr, poststr = utilGetStrs(line, m)

    return f'{prestr}$PWD{poststr}'

# Before: [ a == b ]
# After: [ a = b ]
def noTestDoubleEqualsFixer(line: str, m) -> str:
    prestr, midstr, poststr = utilGetStrs(line, m)

    return f'{prestr}={poststr}'

# Before: function fn() { ...
# After: fn() { ...
# ---
# Before: function fn { ...
# After fn() { ...
def noFunctionKeywordFixer(line: str, m) -> str:
    prestr, midstr, poststr = utilGetStrs(line, m)

    midstr = midstr.strip()
    midstr = midstr[len('function'):]
    midstr = midstr.strip()

    parenIdx = midstr.find('(')
    if parenIdx != -1: midstr = midstr[:parenIdx]

    return f'{prestr}{midstr}() {poststr}'

def lintfile(filepath: Path, rules: List[Rule], options: Dict[str, Any]):
    content_arr = filepath.read_text().split('\n')

    for line_i, line in enumerate(content_arr):
        if 'checkstyle-ignore' in line:
            continue

        for rule in rules:
            m = re.search(rule['regex'], line)
            if m is not None and m.group('match') is not None:
                dir = os.path.relpath(filepath.resolve(), Path.cwd())
                prestr = line[0:m.start('match')]
                midstr = line[m.start('match'):m.end('match')]
                poststr = line[m.end('match'):]

                print(f'{c.CYAN}{dir}{c.RESET}:{line_i + 1}')
                print(f'{c.MAGENTA}{rule["name"]}{c.RESET}: {rule["reason"]}')
                print(f'{prestr}{c.RED}{midstr}{c.RESET}{poststr}')
                print()

                if options['fix']:
                    content_arr[line_i] = rule['fixerFn'](line, m)

                rule['found'] += 1

    if options['fix']:
        filepath.write_text('\n'.join(content_arr))

def main():
    rules: List[Rule] = [
        {
            'name': 'no-double-backslash',
            'regex': '".*?(?P<match>\\\\\\\\[abeEfnrtv\'"?xuUc]).*?(?<!\\\\)"',
            'reason': 'Backslashes are only required if followed by a $, `, ", \\, or <newline>',
            'fixerFn': noDoubleBackslashFixer,
            'testPositiveMatches': [
                'printf "%s\\\\n" "Hai"',
                'echo -n "Hello\\\\n"'
            ],
            'testNegativeMatches': [
                'printf "%s\\n" "Hai"',
                'echo -n "Hello\\n"'
            ],
            'found': 0
        },
        {
            'name': 'no-pwd-capture',
            'regex': '(?P<match>\\$\\(pwd\\))',
            'reason': '$PWD is essentially equivalent to $(pwd) without the overhead of a subshell',
            'fixerFn': noPwdCaptureFixer,
            'testPositiveMatches': [
                '$(pwd)'
            ],
            'testNegativeMatches': [
                '$PWD'
            ],
            'found': 0
        },
        {
            'name': 'no-test-double-equals',
            'regex': '(?<!\\[)\\[ (?:[^]]|](?=}))*?(?P<match>==).*?]',
            'reason': 'Disallow double equals in places where they are not necessary for consistency',
            'fixerFn': noTestDoubleEqualsFixer,
            'testPositiveMatches': [
                '[ a == b ]',
                '[ "${lines[0]}" == blah ]',
            ],
            'testNegativeMatches': [
                '[ a = b ]',
                '[[ a = b ]]',
                '[[ a == b ]]',
                '[ a = b ] || [[ a == b ]]',
                '[[ a = b ]] || [[ a == b ]]',
                '[[ "${lines[0]}" == \'usage: \'* ]]',
                '[ "${lines[0]}" = blah ]',
            ],
            'found': 0
        },
        {
            'name': 'no-function-keyword',
            'regex': '^[ \\t]*(?P<match>function .*?(?:\\([ \\t]*\\))?[ \\t]*){',
            'reason': 'Only allow functions declared like `fn_name() {{ :; }}` for consistency (see ' + c.LINK('https://www.shellcheck.net/wiki/SC2113', 'ShellCheck SC2113') + ')',
            'fixerFn': noFunctionKeywordFixer,
            'testPositiveMatches': [
                'function fn() { :; }',
                'function fn { :; }',
            ],
            'testNegativeMatches': [
                'fn() { :; }',
            ],
            'found': 0
        },
    ]

    parser = argparse.ArgumentParser()
    parser.add_argument('files', metavar='FILES', nargs='*')
    parser.add_argument('--fix', action='store_true')
    parser.add_argument('--internal-test-regex', action='store_true')
    args = parser.parse_args()

    if args.internal_test_regex:
        for rule in rules:
            for positiveMatch in rule['testPositiveMatches']:
                m = re.search(rule['regex'], positiveMatch)
                if m is None or m.group('match') is None:
                    print(f'{c.MAGENTA}{rule["name"]}{c.RESET}: Failed {c.CYAN}positive{c.RESET} test:')
                    print(f'=> {positiveMatch}')
                    print()

            for negativeMatch in rule['testNegativeMatches']:
                m = re.search(rule['regex'], negativeMatch)
                if m is not None and m.group('match') is not None:
                    print(f'{c.MAGENTA}{rule["name"]}{c.RESET}: Failed {c.YELLOW}negative{c.RESET} test:')
                    print(f'=> {negativeMatch}')
                    print()
        print('Done.')
        return

    options = {
        'fix': args.fix
    }

    # parse files and print matched lints
    if len(args.files) > 0:
        for file in args.files:
            p = Path(file)
            if p.is_file():
                lintfile(p, rules, options)
    else:
        for file in Path.cwd().glob('**/*'):
            if file.name.endswith('.bash') or file.name.endswith('.sh') or file.name.endswith('.bats'):
                if file.is_file():
                    lintfile(file, rules, options)

    # print final results
    print(f'{c.UNDERLINE}TOTAL ISSUES{c.RESET}')
    for rule in rules:
        print(f'{c.MAGENTA}{rule["name"]}{c.RESET}: {rule["found"]}')

    grand_total = sum([rule['found'] for rule in rules])
    print(f'GRAND TOTAL: {grand_total}')

    # exit
    if grand_total == 0:
        exit(0)
    else:
        exit(2)

main()
