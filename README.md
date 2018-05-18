# Dlang_array_vec

# Overview

It is an array system like numpy.<br>
It is written in D language.

# Demo

```D:main.d
import vec;
import std.stdio;

void main(){

array!(int) data = array!int.make([[1,2,3],[4,5,6]]);

writef("check1:%s\n",data);

data[1] = array!int.make([1,2,3]);

writef("check2:%s\n",data);
writef("check3:%s\n",data[0,1]);


data=data.ia[1];

writef("check4:%s\n",data);

}

```

print

```shell:print
check1:[
        [1,2,3],
        [4,5,6]
]
check2:[
        [1,2,3],
        [1,2,3]
]
check3:2
check4:[1,2,3]
```

# tutorial

First look at the tutorial.

## English

I am making it.

## Japanese

[document](doc/Japanese/index.md)<br>

[tutorial](doc/Japanese/tutorial.md)
