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

## 結合

~演算子で結合することが出来ます。

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;

void main(){

array!double A=new array!double;

A=A~array!double.make([0.0]);
A=A~array!double.make([1.0]);
A=A~array!double.make([1.0]);
A=A~1.0;
A=A~array!double.make([1.0]);
A~=array!double.make([1.0]);

writeln(A);

}

```

出力

```
[0,1,1,1,1,1]

```

空のvec.arrayに結合するとshapeとdataは結合するvec.arrayと等しくなります。

## Dlang_array_vecの配列からD言語配列へ変換

to_D_arrayを使って下さい。

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;


void main(){

array!(double) data = array!double.make([1,2,3,4,5,6]);

data.resize([2,3]);

auto data2=data.to_D_array!(double[][])();

writeln(data2);
writeln(typeid(typeof(data2)));

}
```

表示

```
[[1, 2, 3], [4, 5, 6]]
double[][]

```

D言語の静的型付けの影響で型指定が必要です。<br>
型がshapeと会わない場合や要素の型と会わない場合などは例外が投げられます。

## デバッグ機能

Dlang_array_vecには先進的でユニークなデバッグ機能が付いています。<br>
その一つが内部デバッグ機能です。<br>
内部デバッグ機能とはvec.arrayクラスメソッドを呼び出すたびに任意の関数を呼び出して、おかしな値がないか全ての要素を精査する事が出来ます。<br>
では、こちらのソースコードをご覧ください。

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;

void main(){

try{
    array!(real) data = array!real.make([0,1,2,3,4,5]);

    data.debug_mode=true;

    data.debug_func=(int[] index,real e,ref string msg){
      msg="number is infinity.";
      return !isInfinity(e);
    };
    //無限大の場合は例外を吐くようにする

    data=vec_math_tool_log(data);
    //0のlogは無限大

  }
  catch(array!real.debug_data_class e){
    writeln(e.index_data);
    writeln(e.elem_data);
    writeln(e);
  }

}
```

出力

```
[0]
-inf
~~~~: number is infinity.
~~~~
例外の吐かれた場所の情報
~~~~
```

まず初めにdebug_modeにtrueを代入すると内部デバッグを行う事が出来ます。<br>
その後、debug_funcに関数を代入します。<br>
debug_funcの関数の引数は(index,elem,例外を吐くときに使用されるメッセージ)です。<br>
debug_funcは例外を吐きたい条件になったらfalseを返してください。<br>
array.debug_data_classにはelem_dataメンバに例外を吐いた時の要素、<br>
にindex_dataメンバに例外を吐いた時のindex、<br>
そして、そのまま出力すると、msgに代入されたメッセージと例外の吐かれた関数の位置が出力されます。<br>


## 高階関数

### fold

foldは関数を一つ一つ実行して、畳み込みます。<br>
詳しくはWikipediaの説明が詳しいでしょう[fold](https://ja.wikipedia.org/wiki/%E9%AB%98%E9%9A%8E%E9%96%A2%E6%95%B0#fold)<br>

```D:main.d

import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.fold!(double)((x1,x2)=>max(x1,x2)));

}

```

表示

```
3

```

#### foldr

右から左に呼び出します。<br>
foldも内部的にはfoldrを呼び出しています。


```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.foldr!(double)((x1,x2)=>max(x1,x2)));

}

```

表示

```
3

```

#### foldl

左から右に呼び出します。<br>

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.foldl!(double)((x1,x2)=>max(x1,x2)));

}

```

表示

```
3

```

### each

一つ一つ、要素ごとに関数を呼び出します。<br>

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

A.each!(double)((x)=>writeln(x));

}

```

表示

```
1
2
3

```

### map

全ての要素に関数を呼び出し、新しいarrayを作成します。

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){

array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.map((x)=>2+x));

array!double A2=array!double.make([[1.0,1.0],[2.0,2.0],[3.0,3.0]]);

writeln(A2.map((x)=>2+x));

}
```

表示

```
[3,4,5]
[
        [3,3],
        [4,4],
        [5,5]
]
```

### filter

条件に合致した関数のみ抽出して新たなarrayを作ります。


```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){

array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.filter!(double)((x)=>1<x));

}

```

表示

```
[2,3]

```

## その他、付属関数

### sum

全ての要素の総和を出します。

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.sum());

}
```

表示


```
6

```

### count

全ての要素で条件に合う数を出します。

```D:main.d

import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.count(2.0));

}

```

表示

```
1

```

関数を指定することもできます。

```D:main.d
import vec;
import vec_math_tool;
import std.stdio;
import std.math;
import std.algorithm : max;

void main(){
array!double A=array!double.make([1.0,2.0,3.0]);

writeln(A.count((x)=>1.0<x));

}

```

表示

```
2

```
