#!/usr/bin/env python
#
# Query the leo.org German/English dictionary.
#
# Copyright (C) 2015 Ian Denhardt <ian@zenhack.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import six
import json
import requests
from lxml import etree
from io import StringIO
import argparse
from tabulate import tabulate

arg_parser = argparse.ArgumentParser(
    description="Query the leo.org German/English dictionary.",
    epilog="Note that the developers of this software are in "
           "no way affiliated with leo.org."
)
arg_parser.add_argument('query',
                        metavar='search-term',
                        nargs='+',
                        help="word(s) to search for")
arg_parser.add_argument('-j', '--json',
                        action='store_true',
                        default=False,
                        help='Format results as JSON.')

section_names = (
    'subst',
    'verb',
    'adjadv',
    'preaep',
    'definition',
    'phrase',
    'example',
)


def _get_text(elt):
    buf = StringIO()

    def _helper(_elt):
        if _elt.text is not None:
            buf.write(six.text_type(_elt.text))
        for child in _elt:
            _helper(child)
        if _elt.tail is not None:
            buf.write(six.text_type(_elt.tail))

    _helper(elt)
    return buf.getvalue()


def search(term, uri='https://dict.leo.org/ende/'):
    resp = requests.get(uri, params={'search': term})
    p = etree.HTMLParser()
    html = etree.parse(StringIO(resp.text), p)
    ret = {}
    for section_name in section_names:
        section = html.find(".//div[@id='section-%s']" % section_name)
        if section is None:
            continue
        ret[section_name] = []
        results = section.findall(".//td[@lang='en']")
        for r_en in results:
            r_de = r_en.find("./../td[@lang='de']")
            ret[section_name].append({
                'en': _get_text(r_en).strip(),
                'de': _get_text(r_de).strip(),
            })
    return ret


def main():
    args = arg_parser.parse_args()
    query = ' '.join(args.query)
    results = search(query)
    if args.json:
        print(json.dumps(results))
    else:
        for section_name in results.keys():
            print(section_name)
            table = [[r['en'], r['de']] for r in results[section_name]]
            print(tabulate(table, headers=['English', 'German']))
            print('')  # Extra newline

if __name__ == '__main__':
    main()
