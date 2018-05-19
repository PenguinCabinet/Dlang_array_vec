# vec.vec_math_tool

D言語のstd.mathのDlang_array_vec版を提供しています。<br>
基本的に、D言語のstd.mathを全要素に行う形になっています。<br>
関数名は基本的に vec_math_tool_ + D言語のstd.mathの関数となっています。<br>
配列の要素の型はdouble、float、realのいずれかを使って下さい。

## 現在提供さている、関数

D言語のstd.mathの関数名で下記のようになっています。

```
"cos","sin","tan","acos","asin","atan","atan2",
"cosh","sinh","tanh","acosh","asinh","atanh",
"exp","exp2","log","log10","log1p","log2","cbrt","erf",
"ceil","floor","nearbyint","rint","lrint","round","lround",
"trunc","sqrt","abs"
```

例えば、D言語のstd.mathのcosに相当する関数をDlang_array_vec上で使いたい場合は

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;


void main(){

array!(double) data = array!double.make([[1,2,3],[4,5,6]]);

data=vec_math_tool_cos(data);
writeln(data);

}
```

としてください。<br>
関数の動作はD言語のstd.mathと全く一緒ですので、詳しくは[std.math](http://www.kmonos.net/alang/d/phobos/std_math.html)をご覧ください。
