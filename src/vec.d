import std.stdio;
import std.algorithm;
import std.exception;
import std.string;
import core.vararg;
import std.conv;

uint my_array_all_multiplication(in uint[] d,in uint n1,in uint n2){
	if(d.length==n1)return 1;

	return d[0..(d.length-n1)].fold!( (a, b) => a*b);
}

uint[] my_array_all_func(T1...)(T1 delegate(T1,T1) func,T1 a){
	A=new int[a[0].length];
	foreach(e1;a){
		foreach(e2;e1){
			A[i]=func(A[i],e2);
		}
	}
	return A;
}

T[] my_array_map_func(T)(T[] a,T delegate(T) func){
	T[] A=new int[a.length];
	foreach(i,e;a){
		A[i]=func(e);
	}
	return A;
}

T[] args_to_array(T)(T[] a){
	return a;
}

T[] args_to_array(T)(T a){
	return [a];
}


/*
array make_array_func1(in array a,in ulong[] s1,in ulong[] s2){

	foreach(i,e;)

	array A;

};*/

class array(T)
{

	T[] data;

	uint[] shape;

	uint[] surface_index_to_index(in int[] i_data,bool Dimensions_check=true){
		if(i_data.length!=shape.length&&Dimensions_check){
			throw new StringException("Dimensions are not equal");
		}

		uint[] A=new uint[i_data.length];
		foreach(i,e;i_data){
			int temp=0;
			if(e<0){
				temp=shape[i]-e;
			}
			else{
				temp=e;
			}

			if(temp>=shape[i]||temp<0){
				throw new StringException("array index is out of range");
			}

			A[i]=temp;
		}

		return A;
	}

	void resize(in uint[] size){
		shape=size.dup;
		if(size.fold!( (a, b) => a*b)<=0){
			throw new StringException("The specified size is less than or equal to 0");
		}
		data=new T[size.fold!( (a, b) => a*b)];
	}

	this(){
		ia=new index_array_class;
	}

	this(in uint[] size){
		ia=new index_array_class;
		resize(size);
	}

	uint Get_dim(){return shape.length;};

	uint[] Get_shape(){return shape;};

	ref T index(in uint[] i_data){
		uint I=0;

		foreach(i,e;i_data){
			I+=my_array_all_multiplication(shape,i+1,shape.length)*e;
		}

		return data[I];
	}

	T Get_index(in uint[] i_data){
		return index(i_data);
	}


	ref T opIndex(T1...)(T1 a){
		int[] index_data=new int[a.length];
		foreach (i,e; a){
			index_data[i]=e;
		}
		return index(surface_index_to_index(index_data));
	}

	bool empty(){return data.length==0;}

	void clear(){
		data=[];
		shape=[];
	}
	void slice(ref array A,in uint[] add_data,ref in uint[] size_data,in uint[] temp_index1=[],in uint[] temp_index2=[]){
		for (uint i=0;i<size_data[temp_index1.length] ; i++) {
			if(size_data.length==temp_index1.length+1){
					A.index(temp_index1~i)=index(temp_index2~(add_data[temp_index1.length]+i));
			}
			else{
				slice(A,add_data,size_data,temp_index1~i,temp_index2~(add_data[temp_index2.length]+i));
			}
		}
	};


	array slice(in int[] a1,in int[] a2){
		if(a1.length==a2.length){
			throw new StringException("The sizes specified for slice are not equal");
		}

		uint[] ta1=surface_index_to_index(a1,false);
		uint[] ta2=[];

		{
			int[] temp=a2.dup;
			foreach(ref e;temp){e-=1;}
			ta2=surface_index_to_index(temp,false);
			foreach(ref e;ta2){e+=1;}
		}

		uint[] size_data=new uint[ta1.length];

		for (uint i=0;i<ta1.length ; i++) {
			size_data[i]=ta2[i]-ta1[i];
		}

		array!(T) A= new array!(T)(size_data);
		slice(A,ta1,size_data);
		return A;
	}

	void index_array(ref array A,in uint[] base_index,in uint[] size_data,in uint[] temp_index=[]){
		for (uint i=0;i<size_data[temp_index.length] ; i++) {
			if(size_data.length==temp_index.length+1){
				A.index(temp_index~i)=index(base_index~temp_index~i);
			}
			else{
				index_array(A,base_index,size_data,temp_index~i);
			}
		}
	};

	array index_array(in uint[] a){
		if(a.length==0){
			throw new StringException("index dimension is 0");
		}
		if(a.length>shape.length){
			throw new StringException("Too many dimensions for index");
		}
		if(a.length==shape.length){
			throw new StringException("Please use opIndex if the dimension size of index is equal to the dimension size of shape");
		}

		array!T A=new array!T(shape[a.length..$]);
		index_array(A,a,shape[a.length..$]);
		return A;
	}

	class index_array_class{
		this(){

		};
		array opIndex(T1...)(T1 a){
			return index_array(surface_index_to_index(args_to_array!int(a),false));
		}
	};

	index_array_class ia;


	array opSlice(in int a1,in int a2){
		auto ta1=surface_index_to_index([a1],false);
		auto ta2=surface_index_to_index([a2-1],false);
		uint[] size_data=[(ta2[0]+1)-ta1[0]];

		if(shape.length>1){
			size_data~=shape[1..$];
		}

		uint[] temp=new uint[shape.length];

		temp[temp.length-1]=a1;

		array!(T) A= new array!(T)(size_data);

		slice(A,temp,size_data);

		return A;
	};

	string range_Make_str(in string a,in uint n){
		string A;
		for (uint i=0;i<n;i++) {
			A~=a;
		}

		return A;
	}

	void toString(ref string A,in uint[] temp_index=[]){
		A~=range_Make_str("\t",temp_index.length);
		A~="[";

		if(shape.length!=temp_index.length+1){
			A~="\n";
		}

		for (uint i=0;i<shape[temp_index.length] ; i++) {
			if(shape.length==temp_index.length+1){
				A~=to!(string)(index(temp_index~i));
				if(i!=shape[temp_index.length]-1)A~=",";
			}
			else{
				toString(A,temp_index~i);
				if(i!=shape[temp_index.length]-1)A~=",";
				A~="\n";
			}
		}

		if(shape.length!=temp_index.length+1){
			A~=range_Make_str("\t",temp_index.length);
		}
		A~="]";

	}

	override string toString(){
		string A="";
		toString(A);
		return A;
	}


};
