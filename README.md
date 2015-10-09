# Benchmark generator

Given a YAML application descriptor, generates a full application
for a number of web frameworks, then let's you benchmark it.

Use it like this:

- `pub global activate benchmark_generator`
- `bench_gen  -i /path/to/descriptor.yaml -o /path/to/output/dir -f ng2-dart`

## Creating application descriptors

An application descriptor is a YAML file that describes the structure of an
application in a framework-independent way. The format is described in the
[example](https://github.com/angular/benchmark_generator/blob/master/example/small.yaml).

If you need to describe an application structure very precisely and you
application isn't very big (dozens of components) you can write a descriptor by
hand.

If you would like to emulate a very large application (hundreds of components)
you might want to consider generating it. For example
[gen_scaffold_spec.dart](https://github.com/angular/benchmark_generator/blob/master/bin/gen_scaffold_spec.dart)
generates a typical mobile web app (a shell containing a sidebar with tabs,
each tab corresponds to a screen). For applications of different structures you
can write your own generator.
