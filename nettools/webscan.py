#!/usr/bin/env python
# webscan.py - Scan web for stuff
#
import sys
import re
from code import interact
from urllib2 import Request
from urllib2 import urlopen
from bs4 import BeautifulSoup

def print_response(rsp):
    """Print urllib2 response"""
    print "HEADERS"
    print "-------"
    print rsp.info()
    print
    print "BODY"
    print "----"
    print rsp.read()

def request_url(url):
    req = Request(url, None, {
        'User-Agent': "Mozilla/5.0 (Windows NT 6.1; rv:27.3) Gecko/20130101 Firefox/27.3"
    })
    return urlopen(req)

def url2server(url):
    rsp = request_url(url)
    info = rsp.info()
    return info.has_key('Server') and info['Server'] or None

def server_scanner():
    sites = [
        "http://www.ynet.co.il",
        "http://www.walla.co.il",
        "http://www.yahoo.com",
        "http://www.facebook.com",
        "http://www.google.com",
    ]
    site_servers = map(lambda u: (u, url2server(u)), sites)
    for site, server in site_servers:
        print "%-40s : %s" % (site, server or "")

def beautify_url(url):
    rsp = request_url(url)
    return BeautifulSoup(rsp.read(), 'html5lib')

def pretify_url(url):
    print beautify_url(url).prettify()

def page_scrape_by_re(retxt, page):
    rx = re.compile(retxt)
    return [rx.match(l).group(0).encode('ascii') for l in page(text = rx) if rx.match(l)]

def spider(url, depth = 0, blacklist = set()):
    pg = beautify_url(url)
    seen = set()
    for a in pg("a"):
        try:
            if not a.has_key('href'):
                continue
            href = a["href"].encode('ascii')
            if re.match(r'^https?://\S+', href):
                seen.add(href)
            elif re.match(r'^/\S+', href):
                seen.add(url + href)
        except UnicodeEncodeError:
            pass
    if depth:
        for u in seen - blacklist:
            seen |= spider(u, depth - 1, seen)
    return seen

def user_agent_list():
    bs = beautify_url('http://www.useragentstring.com/pages/Browserlist/')
    return [a.string for a in bs.select('ul > li > a')]

def main():
    interact(
        banner = "Barak's Python web tools", 
        local = globals()
    )

if __name__ == "__main__":
    sys.exit(main())


