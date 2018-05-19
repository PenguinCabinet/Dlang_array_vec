import std.stdio;
import std.algorithm;
import std.exception;
import std.string;
import core.vararg;
import std.conv;
import std.traits;



class array(T)
{

	class internal_Exception : Exception {
		array!T error_data;

		this(string s){
			super(s);
			error_data= new array!T(shape);
			error_data.data=data;
		}
	};

	static array!T make(T2)(T2 a){
		uint[] temp_shape;

		void temp1(T3)(T3 a1){
			static if(is(T3==string)||!isArray!(T3)){
			}
			else{
				temp_shape~=a1.length;
				temp1(a1[0]);
			}
		};

		temp1(a);

		array!T A= new array!T(temp_shape);

		void temp2(T3)(T3 a1,in uint[] temp_index=[]){
			static if(is(T3==string)||!isArray!(T3)){
				A.index(temp_index)=a1;
			}
			else {
				for (uint i=0;i<A.shape[temp_index.length] ; i++) {
						temp2(a1[i],temp_index~i);
				}
			}
		};

		temp2(a);

		return A;
	};


	private uint my_array_all_multiplication(in uint[] d,in uint n1,in uint n2){
		if(d.length==n1)return 1;

		return d[n1..$].fold!( (a, b) => a*b);
	}

	T[] data;

	uint[] shape;

	private uint[] surface_index_to_index(in int[] i_data,bool Dimensions_check=true){
		if(i_data.length!=shape.length&&Dimensions_check){
			throw new internal_Exception("Dimensions are not equal");
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
				throw new internal_Exception("array index is out of range");
			}

			A[i]=temp;
		}

		return A;
	}

	void resize(in uint[] size){
		shape=size.dup;
		if(shape.length>0&&size.fold!( (a, b) => a*b)<=0){
			throw new internal_Exception("The specified size is less than or equal to 0");
		}
		data.length=size.fold!( (a, b) => a*b);
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

	ref T opIndex(int[] a ...){
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

	private void slice(ref array A,in uint[] add_data,ref in uint[] size_data,in uint[] temp_index1=[],in uint[] temp_index2=[]){
		for (uint i=0;i<size_data[temp_index1.length] ; i++) {
			if(size_data.length==temp_index1.length+1){
					A.index(temp_index1~i)=index(temp_index2~(add_data[temp_index1.length]+i));
			}
			else{
				slice(A,add_data,size_data,temp_index1~i,temp_index2~(add_data[temp_index2.length]+i));
			}
		}
	};


	private array slice(in int[] a1,in int[] a2){
		if(a1.length==a2.length){
			throw new internal_Exception("The sizes specified for slice are not equal");
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

	private void index_array(ref array A,in uint[] base_index,in uint[] size_data,in uint[] temp_index=[]){
		for (uint i=0;i<size_data[temp_index.length] ; i++) {
			if(size_data.length==temp_index.length+1){
				A.index(temp_index~i)=index(base_index~temp_index~i);
			}
			else{
				index_array(A,base_index,size_data,temp_index~i);
			}
		}
	};

	private array index_array(in uint[] a){
		if(a.length==0){
			throw new internal_Exception("index dimension is 0");
		}
		if(a.length>shape.length){
			throw new internal_Exception("Too many dimensions for index");
		}
		if(a.length==shape.length){
			throw new internal_Exception("Please use opIndex if the dimension size of index is equal to the dimension size of shape");
		}

		array!T A=new array!T(shape[a.length..$]);
		index_array(A,a,shape[a.length..$]);
		return A;
	}

	private class index_array_class{
		this(){

		};
		array opIndex(int[] a ...){
			int[] index_data=new int[a.length];
			foreach (i,e; a){
				index_data[i]=e;
			}
			return index_array(surface_index_to_index(index_data,false));
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

	private string range_Make_str(in string a,in uint n){
		string A;
		for (uint i=0;i<n;i++) {
			A~=a;
		}

		return A;
	}

	private void toString(ref string A,in uint[] temp_index=[]){
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

	private void set(array a,uint[] index_data){

		if(shape.length<=index_data.length){
			throw new internal_Exception("The dimension of index is beyond the dimension of the array.");
		}

		if(shape[index_data.length..$]!=a.shape){
			throw new internal_Exception("The shape of the assigned arrays are not equal.");
		}


		void temp(array a,in uint[] temp_index=[]){
			for (uint i=0;i<shape[index_data.length..$][temp_index.length] ; i++) {
				if(shape.length-index_data.length==temp_index.length+1){
					index(index_data~temp_index~i)=a.index(temp_index~i);
				}
				else{
					temp(a,temp_index~i);
				}
			}

		};

		temp(a);
	};

	void opIndexAssign(array a,int[] a2 ...){

		int[] index_data=new int[a2.length];
		foreach (i,e; a2){
			index_data[i]=e;
		}

		set(a,surface_index_to_index(index_data,false));

	}

	void opIndexAssign(T a,int[] a2...){
		opIndex(a2)=a;
	}


	array opUnary(string s)() if (s == "-") {
		array!T A=clone();

		A.shape=shape.dup;
		A.data=-1*data.dup[];

		return A;
	}

	array opBinary(string op)(T a) {
		array!T A=clone();

		if(op=="+"){
			A.data[]+=a;
		}
		if(op=="-"){
			A.data[]-=a;
		}
		if(op=="*"){
			A.data[]*=a;
		}
		if(op=="/"){
			A.data[]/=a;
		}
		if(op=="%"){
			A.data[]%=a;
		}
		if(op=="^^"){
			A.data[]^^=a;
		}

		return A;
	}

	array opBinary(string op)(array a) {
		if(shape!=a.shape){
			throw new internal_Exception("Array shape are not equal.");
		}

		array!T A=new array!T(shape);

		if(op=="+"){
			A.data[]=data[]+a.data[];
		}
		if(op=="-"){
			A.data[]=data[]-a.data[];
		}
		if(op=="*"){
			A.data[]=data[]*a.data[];
		}
		if(op=="/"){
			A.data[]=data[]/a.data[];
		}
		if(op=="%"){
			A.data[]=data[]%a.data[];
		}
		if(op=="^^"){
			A.data[]=data[]^^a.data[];
		}

		return A;
	}

	void opOpAssign(string op)(T a){
		data=opBinary(op)(a).data;
	}

	void opOpAssign(string op)(array a){
		data=opBinary(op)(a).data;
	}


	array clone(){
		array!T A= new array!T(shape);
		A.data=data.dup;
		return A;
	}

	array map(T function(T) func){
		array!T A=clone();
		foreach(ref e;A.data){
			e=func(e);
		};
		return A;
	};

};
