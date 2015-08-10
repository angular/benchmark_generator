# Benchmark generator

Given a YAML application descriptor, generates a full application
for a number of web frameworks, then let's you benchmark it.

Use it like this:

- `pub global activate benchmark_generator`
- `bench_gen  -i /path/to/descriptor.yaml -o /path/to/output/dir -f ng2-dart`
