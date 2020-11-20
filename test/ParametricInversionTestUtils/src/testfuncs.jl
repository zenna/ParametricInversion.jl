# No consts, no duplication 

function f_easy(x, y, z)
  a = x + y
  b = a * z
end

f_easy2(x, y, z) = x * y + z

function f_easy3(x, y, z)
  a = x * y + z
end

function f_easy4(x, y, z)
  x * y + z
end

# Single Block
function g(x)
  2 * x
end

function f(a, b, c)
  x = a + b + 3
  y = x * c
  g(y)
end

# Single Block With Duplication

function f4(a)
  x = a + a
end

function fd(a, b)
  z = a / b
  a + z
end

# Multiple Blocks
function f2(a, b, c)
  x = a + b + 3
  y = a * c
  if x > 3
    g(x + x/y)
  else
    g(y + x)
  end
end

## Recursion

function while1(a, b)
  i = 0
  for i = 1:5
    a = a + b
  end
  a
end

function while2(a, n)
  i = 0
  while i < n
    i += 1
    a = a * n
  end
  a
end