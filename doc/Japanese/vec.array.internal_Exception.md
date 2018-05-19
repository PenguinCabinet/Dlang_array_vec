# vec.array.internal_Exception

vec.array.internal_ExceptionはDlang_array_vec内部の例外用のクラスです。<br>
使い方も普通の例外と同じように使えます。

```D:main.d
import vec;
import std.stdio;



void main(){

array!(int) data = array!int.make([[1,2,3],[4,5,6]]);

try{
	data[0]=1;
	//適切なコード:data[0,0]=1;
}
catch(array!int.internal_Exception e){
	writeln(e);
}

}

```

ただし、要素の型を指定しなければならないことを忘れないで下さい。<br>
何故型が必要かはD言語が静的型付けであることから分かっていただけると思います。<br>

## エラーの中身を確認する

internal_Exceptionにはエラーを起こしたarrayが収納されています。<br>
つまり、すぐに中身を確認する事が出来ます。

```D:main.d
import vec;
import std.stdio;



void main(){

array!(int) data = array!int.make([[1,2,3],[4,5,6]]);

try{
	data[0]=1;
	//適切なコード:data[0,0]=1;
}
catch(array!int.internal_Exception e){
	writeln(e);
  writeln(e.error_data);
  writeln(e.error_data.shape);
}

}

```

表示

```shell:出力
~~~~: Dimensions are not equal
~~~~
情報
~~~~
[
        [1,2,3],
        [4,5,6]
]
[2, 3]
```

例外のarrayのデータはコピーされずに参照されているだけです。<br>
つまり、巨大なデータを扱っていても例外が原因でメモリー不足になる可能性は低いです。
