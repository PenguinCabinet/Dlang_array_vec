# vec.vec_outside_Exception

vec.vec_outside_ExceptionはDlang_array_vecの外での例外用のクラスです。<br>
使い方も普通の例外と同じように使えます。

```D:main.d
import vec;
import std.stdio;

void main(){

try{
  //コード
}
catch(vec_outside_Exception e){
	writeln(e);
}

}

```
