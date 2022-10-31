<!-- Iris image -->
<img src="https://images.unsplash.com/photo-1540163502599-a3284e17072d?w=1000"
style="display:inline-block; float:right; margin:0 0 25px 25px; width: 100%; max-width: 500px;" />


# The Irida Programming Language

> **NOTE** *Irida is a work in progress. Anything can change without prior warning.
Do everything at your own risk.*

Irida is general purpose compiled programming language that targets `x86_64 GNU/Linux`.
It is a stack-based language as you put elements on the stack, and work with
them by arranging them depending on the program.

## Installation

Clone this repository, go to the project's folder and

```console
sudo ./install.sh
```

Once it's done, you will have the `irida` command available on your system.

*Note that you need [dune](https://dune.build) in order to build the project*

## Running

If the Irida program is contained in `file.iri` you would do

```console
irida ./file.iri
```

That will create the executable file with the same name (but without any
extension) in the same folder that the file is. It will also run it.

For help:

```console
irida -help
```

## Examples

The [examples folder](examples/) contains programs that let you see what Irida
is capable of.

### Hello World
```irida
include std

printns: "Hello, world!"
```

### Loop from one to ten
```irida
include std

0
loop
  1 add ddupl
  printni

  10 eq then
    0 exit
  end
end
```

### Factorial
```irida
include std

proc rec fact
  dupl
  is_zero
    then drop 1
    else dupl pred fact mul end
end

fact: 5
  printni
```

---

*Interesting fact*: The name actually comes from the ancient Greek word ίριδα,
which translates to [iris](https://en.wikipedia.org/wiki/Iris_(plant)), a
beautiful garden flower.