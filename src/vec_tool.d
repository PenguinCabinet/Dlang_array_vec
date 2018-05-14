import vec;
import std.random;

T arr_mean(T)(array a){
  return a.data.sum()/a.data.length;
}

array arr_uniform(T)(T a1,T a2,uint size){
  array!T A=new array!T(size);

  for (uint i=0;i<size ; i++) {
    A[i]=uniform(0, 100, rnd);
  }

  return A;
};

array arr_arange(T)(T a2){

  array!T A=new array!T(cast!(uint)(a2));

  for (T i=0;i<a2 ;i++) {
    A[i]=i;
  }
  return A;
};

array arr_arange(T)(T a1,T a2){

  array!T A=new array!T(cast!(uint)(a2-a1));

  for (T i=a1;i<a2 ;i++) {
    A[i]=i;
  }
  return A;
};

array arr_arange(T)(T a1,T a2,T a3){

  array!T A=new array!T(cast!(uint)((a2-a1)/a3));

  for (T i=a1;i<a2 ;i+=a3) {
    A[i]=i;
  }
  return A;
};
