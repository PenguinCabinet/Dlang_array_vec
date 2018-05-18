# D言語の配列をそのまま代入出来ないの?

つまり、こうしたい、ということですね。

```D:main.d
import vec;
import std.stdio;

void main(){

  array!(int) data = [[1,2,3],[4,5,6]];

}
```

**出来ません**、これは意図したものです。<br>
これはD言語の配列と、Dlang_array_vecの配列を区別しにくくなるのを避けるための仕様です。<br>

一度、Dlang_array_vecの配列に変換して代入してください。<br>
変換するにはarray.makeを使います。<br>

```D:main.d
import vec;
import std.stdio;

void main(){

array!(int) data = array!int.make([[1,2,3],[4,5,6]]);
}

```

# 型の例外が多い

D言語の魅力の一つは静的型付けです。<br>
我々はその特性を最大限に活かすために、暗黙の変換を極力減らしています。
