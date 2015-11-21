#!/usr/bin/env python

import json
import requests
from lxml import etree
from io import StringIO
import argparse

arg_parser = argparse.ArgumentParser(
    description="Query the leo.org German/English dictionary."
)
arg_parser.add_argument('query',
                        metavar='search-term',
                        nargs='+',
                        help="word(s) to search for")

section_names = (
    'verb',
    'phrase',
)


def _get_text(elt):
    buf = StringIO()

    def _helper(_elt):
        if _elt.text is not None:
            buf.write(_elt.text)
        for child in _elt:
            _helper(child)
        if _elt.tail is not None:
            buf.write(_elt.tail)

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
    print(json.dumps(search(query)))

if __name__ == '__main__':
    main()
