# Meri
[![Build Status](https://travis-ci.org/wusuopu/meri.svg?branch=master)](https://travis-ci.org/wusuopu/meri)

Meri is a dynamically typed programming language runs on Ruby.
Its name comes from Going Merry(ゴーイング・メリー) which is a ship in the One Piece(ワンピース) manga.

It's a functional programming language which I develop just for fun. It inspired by Python [Mochi](https://github.com/i2y/mochi), and influenced by CoffeeScript, JavaScript, Ruby and Elixir.
It's only a toy with less power.


## Usage
Build the target file.

```
$ bundle install
$ rake build
```

## Example

```
; file:Example1.meri
; This is a comment
fun1 = (a, b)->
  a1 = a + b
  a1 * a1
end
say fun1 1, 2
; ./meri Example1.meri
; Output:
; 9
```

```
; file:Example2.meri
l = [1, 2, "abc"]
d = {"a": 1, "b": 2}
l[1] = 0
d['c'] = 3
say l
say d
; ./meri Example2.meri
; Output:
: [1.0, 0.0, abc]
: {a: 1.0, b: 2.0, c: 3.0}
```
