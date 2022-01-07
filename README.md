<!-- Iris image -->
<img src="https://images.unsplash.com/photo-1540163502599-a3284e17072d?w=1000" style="display:inline-block; float:right; margin:0 0 25px 25px; width: 100%; max-width: 500px;" />


# The Irida Programming Language

> **NOTE** *Irida is a project that is in progress. Anything can change without prior warning. Do everything at your own risk.*

Irida is general purpose compiled programming language that targets `x86_64 GNU/Linux`. It works with the concept of being stack-based, you put things on the stack, work with them by arranging them depending on your needs.

## Examples

The [examples folder](examples/) contains programs that let you see what Irida is capable of.

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

*Interesting fact*: The name actually comes from the ancient Greek word ίριδα, which translates to iris.