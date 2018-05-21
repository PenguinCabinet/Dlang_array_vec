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
そして、そのまま出力すると、msgに代入されたメッセージと関数の位置が出力されます。<br>
