## Tools

We are using `hey` to benchmark these different frameworks.
The following command is for 100 concurrent requests and
1000 total requests sent to the endpoint under test.

```
hey -m GET -c 100 -n 1000 'http://localhost:80/api/health'
```

| Framework | 10/1k | 100/1k | 1000/1k           | Notes                        |
| --------- | ----- | ------ | ----------------- | ---------------------------- |
| Laravel   | 0.152 | 1.26   | 2.92, 73% dropped | Very consistent results      |
| Rails     | 0.197 | 3.02   | 8.6, 80% dropped  | 90% much faster than Laravel |

- _Results are for 99% latency_

## Laravel

- Added `GET /api/health` endpoint in Api.php
- Disabled `throttle` middleware in `Kernel.php`
- Run with `./bin/sail up`
- Endpoint `http://localhost:80/api/health`

Notes:

- Tools feel crusty, but well thought out
- Choked under high concurrency
- Not sure if `sail up` is representative of performance

## Rails

- Added `GET /health` endpoint via `rails generate controller health`
- Run with `bin/rails server`
- Endpoint `http://localhost:3000/health`

Notes:

- Results didn't seem as consistent as Laravel
- Ran with min threads 5, max threads 5 (default)
- No built in rate limiting
