# vec.array

このライブラリで最も基本的で根幹を支えるのがこのクラスです。

## indexのアクセス方法

詳しくは[チュートリアル](tutorial.md)をご覧ください。

## 四則演算とべき乗

vec.arrayは数値やvec.arrayの配列同士で和、差、積、商、べき乗を求める事が出来ます。

```D:main.d
import vec;
import std.stdio;

void main(){

array!(double) data1 = array!double.make([[1,2,3],[4,5,6]]);
array!(double) data2 = array!double.make([[1,2,3],[4,5,6]]);

array!(double) A=data1+data2*2;

writeln(A);
}
```

表示

```
[
        [3,6,9],
        [12,15,18]
]
```

数値は全ての要素に、配列はそれぞれ対応する要素に演算を行います。

### 注意点

#### 配列は必ずshapeが全て等しくなければならない

これは違う形状の配列を演算して混乱を起きないようにしています。<br>
万が一、違う形状で行うと例外、[vec.array.internal_Exception](vec.array.internal_Exception.md)が投げられます。


### 数式の開始がvec.arrayでなければならない

つまり、

```D:main.d
import vec;
import std.stdio;

void main(){

array!(double) data1 = array!double.make([[1,2,3],[4,5,6]]);
array!(double) data2 = array!double.make([[1,2,3],[4,5,6]]);

array!(double) A=2*data2;

writeln(A);
}
```

や


```D:main.d
import vec;
import std.stdio;

void main(){

array!(double) data1 = array!double.make([[1,2,3],[4,5,6]]);
array!(double) data2 = array!double.make([[1,2,3],[4,5,6]]);

array!(double) A=data1+2*data2;

writeln(A);
}
```

はコンパイルエラーを吐きます。<br>
これは、D言語の演算子の仕様なので改善方法はありません。


## resize

データを維持しつつ、shapeを書き換えます。(縮小の場合は後ろから消える)

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;


void main(){

array!(double) data = array!double.make([1,2,3,4,5,6]);

writeln(data);

writeln(data.shape);

data.resize([2,3]);

writeln("resize");

writeln(data);

writeln(data.shape);

}
```

表示


```
[1,2,3,4,5,6]
[6]
resize
[
        [1,2,3],
        [4,5,6]
]
[2, 3]

```
