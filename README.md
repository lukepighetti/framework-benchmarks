## Tools

We are using `hey` to benchmark these different frameworks.
The following command is for 100 concurrent requests and
1000 total requests sent to the endpoint under test.

```
hey -m GET -c 100 -n 1000 'http://localhost:80/api/health'
```

| Framework        | 10/1k   | 100/1k | 1000/1k             | Notes                              |
| ---------------- | ------- | ------ | ------------------- | ---------------------------------- |
| Laravel          | 0.152   | 1.26   | 2.92, 73% dropped   | Very consistent results            |
| Laravel (Octane) | 0.018\* | 0.23\* | 0.163\* 72% dropped | \* hot start time (see discussion) |
| Rails            | 0.197   | 3.02   | 8.6, 80% dropped    | 90% much faster than Laravel       |
| FastAPI          | 0.004   | 0.016  | 0.074, 69% dropped  | Fast concurrency saturation        |
| shelf (jit)      | 0.005   | 0.053  | 0.061, 55% dropped  | Good high concurrency              |
| shelf (n10)      | 0.006   | 0.017  | 0.061, 68% dropped  | JIT, 10 isolates                   |
| shelf (exe)      | 0.004   | 0.032  | 0.063, 65% dropped  | Slightly improved                  |
| django           | 0.063   | 0.441  | 0.274, 91% dropped  | Faster than other frameworks       |
| djangicorn       | 0.015   | 0.163  | 0.303, 77% dropped  | Much faster than other frameworks  |

- _Results are for 99% latency_

## Laravel

- Added `GET /api/health` endpoint in Api.php
- Disabled `throttle` middleware in `Kernel.php`
- Run with `./vendor/bin/sail up`
- Endpoint `http://localhost:80/api/health`

Notes:

- Tools feel crusty, but well thought out
- Choked under high concurrency
- Not sure if `sail up` is representative of performance

## Laravel (Octane)

- Duplicated `laravel` folder
- Installed octane and Roadrunner, patched Dockerfiles
- Run with `./vendor/bin/sail up`

Notes

- Complex response times
- Very good performance
- Needs fresh docker build after running plain laravel due to image name collisions

Discussion

The response times were complex. PHP bootstraps the server on each request, while Octane apparently reuses some of these resources on subsequent requests. The results showed a slower bootstrap time, but a much faster subsequent time. This compares to the "hot start" / "cold start" mental model that is common in serverless architectures. The speed in practise is greately improved with Octane, but we had to adjust which numbers we were presenting to filter out the cold start times.

This actually shows a flaw in our testing methodology. It's probably better to run a tiered test where we start with c=50, then up to c=100, 200, 300 and so on. This allows the server to "warm up" and is probably more indicative of realworld performance. This pattern is common when testing with k6. Here is some [prior art](https://github.com/SirusCodes/backend_benchmark/blob/main/scripts/k6_load_testing.js)

## Rails

- Added `GET /health` endpoint via `rails generate controller health`
- Run with `bin/rails server`
- Endpoint `http://localhost:3000/health`

Notes:

- Results didn't seem as consistent as Laravel
- Ran with min threads 5, max threads 5 (default)
- No built in rate limiting

## FastAPI

- Added `GET /health` endpoint in `main.py`
- Run with `pipenv run uvicorn main:app --workers $(nproc)`
- Test machine ran with 10 workers
- Endpoint `http://localhost:8000/health`

Notes:

- Definitely the fastest by far
- Also the smallest feature set... not a complete framework
- Still fast even during concurrency saturation

## Shelf

- Added `GET /health` endpoint in `bin/api.dart`
- Run with `dart bin/api.dart` in JIT mode and exe mode
- No setting for number of workers
- Endpoint `http://localhost:8080/health`

Notes:

- Results were very consistent
- Dropped fewer requests in high concurrency test in some cases
- Run in JIT mode with single thread and multiple isolates, EXE mode with single thread

## Django

- Added `GET /health` endpoint in `api/views.py`
- Run with `pipenv run python manage.py runserver`
- No setting for number of workers
- Endpoint `http://localhost:8000/health`

Notes:

- Faster than other large frameworks
- Buckled under high concurrency

## Djangicorn

- Copy of Django from above, but running Uvicorn
- Ran with 10 workers

Notes:

- Remarkably fast. Much faster than other large frameworks
