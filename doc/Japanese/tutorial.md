# 初めに

初めにimportしないと始められません。<br>
このプロジェクトをクローンしてsrcファイルをコピーしてください。<br>
以上で導入は完了です

# 配列の定義

このライブラリの操作感はnumpy風です。<br>
まずは配列定義してみましょう

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)();
}

```

これで配列の定義は完了です。<br>
早速、コンパイルしてみましょう。


```shell:コンパイル
dmd -Isrc/　src/vec_outside_Exception.d src/vec_math_tool.d src/vec.d main.d
```

お気づきの方もいらっしゃると思いますが、要素の型を変えることもできます。

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(double) data = new array!(double)();
}

```

しかし、これだと、配列は空です。<br>
配列に値を代入する前にサイズを決めなければなりません。<br>
ここでは5×5×5の3次元の配列を作ってみましょう

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)([5,5,5]);
  writef("%s\n",data.shape);
  writef("%s\n",data);
}

```

表示

```shell:出力
[5, 5, 5]
[
        [
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]
        ],
        [
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]
        ],
        [
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]
        ],
        [
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]
        ],
        [
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]
        ]
]
```

自動的にデータを整形して文字列化してくれます。<br>
要素は配列の型のプロパティinitの値が代入されます。(つまり自動的に初期化される)<br>

# 配列の使い方

## index(要素の取得)

配列を作ったので値を代入してみましょう。

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)([5,5,5]);
	data[0,0,0]=1;
  writef("%s\n",data[0,0,0]);
}

```

表示

```shell:出力
1

```

## index(配列の取得)

配列を一部分だけ切り取って、新たな配列を作ります。

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)([5,5,5]);
	data=data.ia[0,0];
  writef("%s\n",data.shape);
}

```

表示

```shell:出力
[5]

```

注意すべき点が二つあります。<br>
<br>
一つ目はia(index_arrayの略)にアクセスしなければならないことです。

```D:main.d
import vec;
import std.stdio;

void main(){
    array!(ulong) data = new array!(ulong)([5,5,5]);
    data=data[0,0];
  writef("%s\n",data.shape);
}

```

とするとコンパイルエラーを吐きます。<br>
この問題はD言語の型と密接に関わっており、問題解決は困難です。<br><br>

もう一つはこれは**新たな配列**が作られている点です。<br>
よって、下記のソースコードはコンパイルエラーを吐きます。

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)([5,5,5]);
	data.ia[0,0]=new array!(ulong)([2]);
  writef("%s\n",data.shape);
}

```

この仕様は将来的に修正されるかもしれません。<br>


## スライス

スライスも備わっています。<br>
これも**新たな配列**が作られています<br>

```D:main.d
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)([5,5,5]);
	data=data[1..4];
  writef("%s\n",data.shape);
}

```

表示

```shell:出力
[3, 5, 5]

```

indexとスライスを組み合わせると強力なことも出来ます。

```D:main.d
//index 0を1..4にスライスする
import vec;
import std.stdio;

void main(){
	array!(ulong) data = new array!(ulong)([5,5,5]);
	data=data.ia[0][1..4];
  writef("%s\n",data.shape);
}

```

表示

```shell:出力
[3, 5]

```

## D言語配列をDlang_array_vecの配列へ変換

array.makeを使って下さい。

```D:main.d
import vec;
import std.stdio;

void main(){

array!(int) data = array!int.make([[1,2,3],[4,5,6]]);
}

```

## indexを指定して配列に代入する

直感的に代入出来ます。

```D:main.d
import vec;
import std.stdio;

void main(){

array!(int) data = array!int.make([[1,2,3],[4,5,6]]);

writef("%s\n",data);

data[1] = array!int.make([1,2,3]);

writef("%s\n",data);
}

```

表示

```
[
        [1,2,3],
        [4,5,6]
]
[
        [1,2,3],
        [1,2,3]
]
```
