#!/bin/bash
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RxDock/run_rxdock | tee last_run.log