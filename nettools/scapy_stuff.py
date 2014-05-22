#!/usr/bin/env python
# scapy_stuff.py - Various funtion to load into Scapy
#
import sys
from threading import *
from scapy.all import *
from netaddr import IPNetwork
import time

class host(object):
    def __init__(self, ip):
        self.ip = ip
        self._ports = {}

    def _on_sniffed_packet(self, pck):
        if isinstance(pck[1], TCP):
            self._on_sniffed_tcp(pck[1])

    def _on_sniffed_tcp(self, tcp):
        if tcp.sprintf("%flags%") == 'SA':
            self.port_by_number(tcp.sport)

    def port_by_number(self, pn):
        if self._ports.has_key(pn):
            return self._ports[pn]
        else:
            p = port(pn)
            self._ports[pn] = p
            return p

    def ports(self):
        return self._ports.keys()

    def synscan(self, ports = [22, 23, 80]):
        for port in ports:
            send(IP(dst=self.ip)/TCP(dport=port,flags="S"))

    def show(self):
        return self.ip + \
            (self.ports() and " (%s)" % (", ".join(map(str, self.ports()))) or '')

class port(object):
    def __init__(self, number):
        self.number = number

class hostlist(object):
    def __init__(self):
        self._list = {}
        self._sniffer_thread = None

    def sniff(self, timeout = 10):
        sniff(timeout = timeout, prn = self._on_sniffed_packet)

    def _sniffer(self):
        while not self._stop_sniffer:
            self.sniff(timeout = 2)

    def runsniffer(self):
        if self._sniffer_thread and self._sniffer_thread.is_alive:
            return
        self._stop_sniffer = False
        self._sniffer_thread = Thread(target = self._sniffer)
        self._sniffer_thread.daemon = True
        self._sniffer_thread.start()
        time.sleep(1)

    def stopsniffer(self):
        self._stop_sniffer = True
        if self._sniffer_thread and self._sniffer_thread.is_alive:
            self._sniffer_thread.join()

    def _on_sniffed_packet(self, pck):
        if isinstance(pck[1], ARP):
            self._on_sniffed_arp(pck[1])
        elif isinstance(pck[1], IP):
            self._on_sniffed_ip(pck[1])

    def _on_sniffed_arp(self, arp):
        self.host_by_ip(arp.sprintf("%psrc%"))
        self.host_by_ip(arp.sprintf("%pdst%"))

    def _on_sniffed_ip(self, ip):
        self.host_by_ip(ip.src)._on_sniffed_packet(ip)

    def host_by_ip(self, ip):
        if self._list.has_key(ip):
            return self._list[ip]
        else:
            h = host(ip)
            self._list[ip] = h
            return h

    def ips(self):
        return self._list.keys()

    def show(self):
        return "\n".join(map(host.show, self._list.values()))

class scanui(object):
    def __init__(self):
        self.hl = hostlist()

    def menu(self, width = 80):
        if not self.hl._list:
            return ""
        mstr = ""
        m = map(host.show, self.hl._list.values())
        maxwidth = max(map(len, m)) + 2
        columns = width / maxwidth
        rows = len(m) / columns + (len(m) % columns > 0)
        for i in range(0, rows):
            for j in range(i, len(m), rows):
                mstr += ("%-" + str(maxwidth) + "s") % (m[j])
            mstr += "\n"
        print mstr

    def start(self):
        self.hl.runsniffer()

    def stop(self):
        self.hl.stopsniffer()


if __name__ == "__main__":
    exit(interact(
	mydict = globals(), 
	mybanner = "Scapy, with some stuff added"
    ))


