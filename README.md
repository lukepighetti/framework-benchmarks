## Tools

We are using `hey` to benchmark these different frameworks.
The following command is for 100 concurrent requests and
1000 total requests sent to the endpoint under test.

```
hey -m GET -c 100 -n 1000 'http://localhost:80/api/health'
```

| Framework | 10/1k | 100/1k | 1000/1k           |
| --------- | ----- | ------ | ----------------- |
| Laravel   | 0.152 | 1.26   | 2.92, 73% dropped |

- _Results are for 99% latency_

## Laravel

- Added `GET /api/health` endpoint in Api.php
- Disabled `throttle` middleware in `Kernel.php`
- Run with `./bin/sail up`
- Endpoint `http://localhost:80/api/health`
