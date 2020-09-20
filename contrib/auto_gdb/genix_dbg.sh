#!/bin/bash
# use testnet settings,  if you need mainnet,  use ~/.autxcore/autxd.pid file instead
autx_pid=$(<~/.autxcore/testnet3/autxd.pid)
sudo gdb -batch -ex "source debug.gdb" autxd ${autx_pid}
