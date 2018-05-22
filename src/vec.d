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


	private class debug_data_class : Exception{
		uint[] index_data;
		T elem_data;

		this(string s,uint[] i,T elem){
			super(s);
			index_data=i.dup;
			elem_data=elem;
		}
	};

	bool debug_mode=false;
  bool delegate(uint[],T,ref string) debug_func;
	bool Is_debug_running=false;


	private void debug_check_func2(uint[] temp_index){
		if(debug_func is null)return;
		if(shape.length==0)return;

		if(temp_index.length==shape.length){
			string msg;
			if(!debug_func(temp_index,opIndex(temp_index),msg)){
				throw new debug_data_class(msg,temp_index,opIndex(temp_index));
			}
		}
		else{
			for (uint i=0;i<shape[temp_index.length] ; i++) {
				debug_check_func2(temp_index~i);
			}
		}
	};

	private void debug_check_func2(array a,uint[] temp_index){
		if(debug_func is null)return;
		if(shape.length==0)return;

		if(temp_index.length==shape.length){
			string msg;
			if(!debug_func(temp_index,a.opIndex(temp_index),msg)){
				throw new debug_data_class(msg,temp_index,a.opIndex(temp_index));
			}
		}
		else{
			for (uint i=0;i<a.shape[temp_index.length] ; i++) {
				debug_check_func2(a,temp_index~i);
			}
		}
	};

	private void debug_check_func(){

		if(!Is_debug_running&&debug_mode){
			Is_debug_running=true;
			debug_check_func2([]);
			Is_debug_running=false;
		}
	}

	private void debug_check_func(array[] a ...){
		if(!Is_debug_running&&debug_mode){
				Is_debug_running=true;
				for (uint i=0;i<a.length ; i++) {
					debug_check_func2(a[i],[]);
				}
				Is_debug_running=false;
		}
	}

	private void check_damage(){

		if(shape.length>0){
			if(data.length!=shape.fold!( (a, b) => a*b)){
				throw new internal_Exception("Shape length and data length are not equal, array is corrupted.");
			};
		}
		else{
			if(data.length>0){
				throw new internal_Exception("Shape length and data length are not equal, array is corrupted.");
			};
		}
	}

	private uint[] surface_index_to_index(in uint[] i_data,bool Dimensions_check=true){
		if(i_data.length!=shape.length&&Dimensions_check){
			throw new internal_Exception("Dimensions are not equal");
		}

		uint[] A=new uint[i_data.length];
		foreach(i,e;i_data){
			uint temp=0;
			temp=e;

			if(temp>=shape[i]||temp<0){
				throw new internal_Exception("array index is out of range");
			}

			A[i]=temp;
		}

		return A;
	}

	void resize(in uint[] size){
		check_damage();
		shape=size.dup;
		if(size.length>0&&size.fold!( (a, b) => a*b)<=0){
			throw new internal_Exception("The specified size is less than or equal to 0");
		}
		if(size.length!=0){
			data.length=size.fold!( (a, b) => a*b);
		}

		debug_check_func();
	}

	this(){
		ia=new index_array_class;
	}

	this(in uint[] size){
		ia=new index_array_class;
		resize(size);
	}

	uint Get_dim(){
		check_damage();
		debug_check_func();
		return shape.length;
	};

	uint[] Get_shape(){
		check_damage();
		debug_check_func();
		return shape;
	};

	ref T index(in uint[] i_data){
		check_damage();

		uint I=0;

		foreach(i,e;i_data){
			I+=my_array_all_multiplication(shape,i+1,shape.length)*e;
		}

		debug_check_func();
		return data[I];
	}

	ref T opIndex(uint[] a ...){
		check_damage();

		uint[] index_data=new uint[a.length];
		foreach (i,e; a){
			index_data[i]=e;
		}

		debug_check_func();
		return index(surface_index_to_index(index_data));
	}

	bool empty(){
		check_damage();
		debug_check_func();
		return data.length==0;
	}

	void clear(){
		check_damage();
		data=[];
		shape=[];
		debug_check_func();
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


	private array slice(in uint[] a1,in uint[] a2){
		if(a1.length==a2.length){
			throw new internal_Exception("The sizes specified for slice are not equal");
		}

		uint[] ta1=surface_index_to_index(a1,false);
		uint[] ta2=[];

		{
			uint[] temp=a2.dup;
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
		array opIndex(uint[] a ...){
			check_damage();
			uint[] index_data=new uint[a.length];
			foreach (i,e; a){
				index_data[i]=e;
			}
			debug_check_func();
			return index_array(surface_index_to_index(index_data,false));
		}
	};

	index_array_class ia;


	array opSlice(in uint a1,in uint a2){
		check_damage();
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

		debug_check_func(A);
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
		check_damage();
		string A="";
		toString(A);
		debug_check_func();
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

	void opIndexAssign(array a,uint[] a2 ...){
		check_damage();

		uint[] index_data=new uint[a2.length];
		foreach (i,e; a2){
			index_data[i]=e;
		}

		set(a,surface_index_to_index(index_data,false));

		debug_check_func();
	}

	void opIndexAssign(T a,uint[] a2...){
		check_damage();

		opIndex(a2)=a;

		debug_check_func();
	}


	array opUnary(string s)() if (s == "-") {
		check_damage();

		array!T A=clone();

		A.shape=shape.dup;
		A.data=-1*data.dup[];

		debug_check_func(A);
		return A;
	}

	array opBinary(string op)(T a) {
		check_damage();

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
		if(op=="~"){
			if(empty()){
				A.shape=[1];
				A.data=[a];
			}
			else{
				if(A.shape.length==1){
					uint[] temp=A.shape.dup;
					temp[0]++;
					A.resize(temp);
					temp[0]--;
					A[temp[0]]=a;
				}
				else{
					throw new internal_Exception("This dimension different join is not supported.");
				}
			}
		}

		debug_check_func(A);
		return A;
	}

	array opBinary(string op)(array a) {
		check_damage();

		if(op!="~"){
			if(shape!=a.shape){
				throw new internal_Exception("Array shape are not equal.");
			}
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
		if(op=="~"){
			if(empty()){
				A=a.clone();
			}
			else{
				A=clone();
				if(A.shape.length==a.shape.length){
					if(A.shape.length>1&&A.shape[1..$]!=a.shape[1..$]){
						throw new internal_Exception("The shape to be joined are not equal.");
					}

					uint[] temp=A.shape.dup;
					temp[0]+=a.shape[0];
					auto temp2=A.shape[0];
					A.resize(temp);

					for (uint i=temp2;i<A.shape[0] ; i++) {
						if(a.shape.length==1){
							A[i]=a[i-temp2];
						}
						else{
							A[i]=a.ia[i-temp2];
						}
					}
				}
				else if(A.shape.length==a.shape.length+1){
					if(A.shape.length>1&&shape[1..$]!=a.shape){
						throw new internal_Exception("The shape to be joined are not equal.");
					}
					uint[] temp=A.shape.dup;
					temp[0]++;
					A.resize(temp);
					temp[0]--;
					A[temp[0]]=a.clone();

				}
				else{
					throw new internal_Exception("This dimension different join is not supported.");
				}
			}
		}

		debug_check_func(A);
		return A;
	}

	void opOpAssign(string op)(T a){
		check_damage();

		array!T temp=opBinary!(op)(a);

		data=temp.data;
		shape=temp.shape;

		debug_check_func();
	}

	void opOpAssign(string op)(array a){
		check_damage();

		array!T temp=opBinary!(op)(a);

		data=temp.data;
		shape=temp.shape;

		debug_check_func();
	}


	array clone(){
		check_damage();

		array!T A= new array!T(shape);
		A.data=data.dup;

		debug_check_func();

		return A;
	}

	array map(T delegate(T) func){
		check_damage();

		array!T A=clone();
		foreach(ref e;A.data){
			e=func(e);
		};

		debug_check_func(A);

		return A;
	};

	array filter(T1)(bool delegate(T1) func){
		check_damage();

		if(shape.length>1&&!is(T1==array)){
			throw new internal_Exception("Element type and function argument types are not equal.");
		}
		if(shape.length==1&&!is(T1==T)){
			throw new internal_Exception("Element type and function argument types are not equal.");
		}

		array!T A=new array!T(shape);

		uint n=0;

		for (uint i=0;i<shape[0] ; i++) {
			static if(is(T1==array)){
				if(func(ia[i])){
					A[n]=ia[i];
					n++;
				}
			}
			static if(is(T1==T)){
				if(func(opIndex(i))){
					A[n]=opIndex(i);
					n++;
				}
			}
		}

		uint[] temp=A.shape.dup;

		temp[0]=n;

		A.resize(temp);

		debug_check_func(A);

		return A;
	}

	void each(T1)(void delegate(T1) func){
		check_damage();

		if(shape.length==0)return;
		if(shape.length>1&&!is(T1==array)){
			throw new internal_Exception("Element type and function argument types are not equal.");
		}
		if(shape.length==1&&!is(T1==T)){
			throw new internal_Exception("Element type and function argument types are not equal.");
		}

		for (uint i=0;i<shape[0] ; i++) {
			static if(is(T1==array)){
				func(ia[i]);
			}
			static if(is(T1==T)){
				func(opIndex(i));
			}
		}

		debug_check_func();
	}

	T1 fold(T1)(T1 delegate(T1,T1) func){
		return fold!(1,T1)(func);
	}

	T1 foldr(T1)(T1 delegate(T1,T1) func){
		return fold!(1,T1)(func);
	}

	T1 foldl(T1)(T1 delegate(T1,T1) func){
		check_damage();

		if(shape.length==0){
			throw new internal_Exception("You can not call fold with an empty array.");
		}
		return fold!(-1,T1)(func,shape[0]-1);
	}

	private T1 fold(const int direction, T1)(T1 delegate(T1,T1) func,uint n=0){
		check_damage();

		if(shape.length==0){
			throw new internal_Exception("You can not call fold with an empty array.");
		}
		if(shape.length>1&&!is(T1==array)){
			throw new internal_Exception("Element type and function argument types are not equal.");
		}
		if(shape.length==1&&!is(T1==T)){
			throw new internal_Exception("Element type and function argument types are not equal.");
		}

		static if(direction==1){
			if(n+1>=shape[0]){
				debug_check_func();
				static if(is(T1==array)){
					return ia[n];
				}
				else{
					return opIndex(n);
				}
			}
			else{
				T1 temp=fold!(direction,T1)(func,n+1);

				static if(is(T1==array)){
					T1 temp2=func(ia[n],temp);
				}
				else{
					T1 temp2=func(opIndex(n),temp);
				}

				debug_check_func();
				return temp2;
			}
		}
		else{
			if(n==0){
				debug_check_func();
				static if(is(T1==array)){
					return ia[n];
				}
				else{
					return opIndex(n);
				}
			}
			else{
				T1 temp=fold!(direction,T1)(func,n-1);

				static if(is(T1==array)){
					T1 temp2=func(ia[n],temp);
				}
				else{
					T1 temp2=func(opIndex(n),temp);
				}

				debug_check_func();
				return temp2;
			}
		}


	}

	T sum(){
		check_damage();

		T A=0;
		foreach(e;data){
			A+=e;
		}
		debug_check_func();
		return A;
	}


	private T3 to_D_array2(T3)(T3 A,uint[] temp_index=[]){

		static if(is(T3==string)||!isArray!(T3)){
			if(temp_index.length!=shape.length)
				throw new internal_Exception("Destination type and shape dimension are not equal.");

			if(!is(T==T3))
				throw new internal_Exception("The type of the element of the destination array and the type of the element of the source array are not equal.");

			return opIndex(temp_index);
		}
		else {
			T3 A1;
			A1.length=shape[temp_index.length];
			for (uint i=0;i<shape[temp_index.length] ; i++) {
					A1[i]=to_D_array2(A1[i],temp_index~i);
			}
			return A1;
		}
	}

	T1 to_D_array(T1)() if(!is(T1==string)||isArray!(T1)) {
		check_damage();
		T1 A;
		debug_check_func();
		return to_D_array2!(T1)(A);
	}

	uint count(T a){
		check_damage();

		uint A=0;
		foreach(ref e;data){
			if(e==a)A++;
		}

		debug_check_func();
		return A;
	}

	uint count(bool delegate(T) func){
		check_damage();

		uint A=0;
		foreach(e;data){
			if(func(e))A++;
		}

		debug_check_func();
		return A;
	}

	uint count(bool delegate(array) func){
		check_damage();

		if(shape.length==0)return 0;

		uint A=0;
		for(uint i=0;i<shape[0];i++){
			if(func(ia[i]))A++;
		}
		debug_check_func();

		return A;
	}

	array!T1 Get_cast(T1)(){
		check_damage();
		static if(is(T1==T)){
			debug_check_func();
			return clone();
		}
		else{
			array!T1 A=new array!T1(shape);
			foreach(i,e;data){
				A.data[i]=to!(T1)(e);
			}
			debug_check_func();
			return A;
		}
	}
};
