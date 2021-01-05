#pragma once

#include <assert.h>
#include <stdint.h>
#include <iostream>
#include <cstdlib>
#include <cmath>

template<typename _T>
_T max(_T a,_T b)
{
  return (a>b)?a:b;
}

class __qfp32
{
public:
  friend class Qfp32Test;

  __qfp32()
  {
    mant=0;
    exp=0;
    sign=0;
  }

  __qfp32(uint32_t sign,uint32_t exp,uint32_t mant)
  {
    this->mant=mant&0x1FFFFFFF;
    this->exp=exp&3;
    this->sign=sign&1;

    if(mant == 0)
    {
      assert(exp == 0);
      sign=0;
    }
  }

  __qfp32(int32_t i)
  {
    int64_t t=i;
    initFromUnnormalized(t<<24);
  }

  __qfp32(const __qfp32 &cpy)
  {
    this->operator=(cpy);
  }

  __qfp32(float value)
  {
    *this=fromDouble(value);
  }

  __qfp32(double value)
  {
    *this=fromDouble(value);
  }

  static __qfp32 fromDouble(double f)
  {
    uint32_t sign=f<0?1:0;

    int32_t intPart__=static_cast<int32_t>(f);
    int32_t realPart__=static_cast<int32_t>((f-intPart__)*(1<<24)+0.5*(sign?-1:1));

    uint32_t intPart=(sign?-1:1)*intPart__;
    uint32_t realPart=(sign?-1:1)*realPart__;
    intPart&=0x1FFFFFFF;
    realPart&=0xFFFFFF;

    if(intPart < 32)
      return __qfp32(sign,0,(intPart<<24)+realPart);

    if(intPart < 32*256)
      return __qfp32(sign,1,(intPart<<16)+(realPart>>8));

    if(intPart < 32*65536)
      return __qfp32(sign,2,(intPart<<8)+(realPart>>16));

    if(intPart < 32*16777216)
      return __qfp32(sign,3,intPart);

    return __qfp32(sign,3,0x1FFFFFFF);
  }
  
  static __qfp32 initFromRaw(uint32_t rawData)
  {
    __qfp32 result;
    result.asUint=rawData;
    return result;
  }
  
  uint32_t toRaw() const { return asUint; }

  __qfp32& operator=(const __qfp32 &rhs)
  {
    mant=rhs.mant;
    exp=rhs.exp;
    sign=rhs.sign;
    return *this;
  }

  __qfp32 operator+(const __qfp32 &rhs) const
  {
    __qfp32 a=*this;
    __qfp32 b=rhs;
    __qfp32 result;

    bool gt=b.exp > a.exp;
    bool eq=b.exp == a.exp;

    uint32_t newExp=max(a.exp,b.exp);

    uint32_t ra=a.changeExp(newExp);
    uint32_t rb=b.changeExp(newExp);

    uint32_t ma=a.mant;
    uint32_t mb=b.mant;

    bool sub=a.sign^b.sign;

    bool negA=false;
    bool negB=false;
    bool cy=false;

    gt=gt || (eq && b.mant>a.mant);

    uint32_t sign=0;

    if(sub)
    {
      negA=gt;
      negB=gt^1;
      cy=1;

      if(gt)
        sign=b.sign;
      else
        sign=a.sign;
    }
    else
      sign=a.sign;

    if(negA)
      ma=~ma;

    if(negB)
      mb=~mb;

    uint32_t res=ma+mb+(cy?1:0);

    if(sub)
    {
      if(((gt && ra) || (!gt && rb)))
        --res;
    }
    else//round
      if(ra || rb)
        ++res;


    res&=0x3FFFFFFF;

    if(sub)
      res&=0x1FFFFFFF;//disable overflow

    int64_t raw=res;
    raw*=sign?-1:1;
    result.initFromUnnormalized(raw<<(newExp*8));

    return result;
  }

  __qfp32 operator-(const __qfp32 &rhs) const
  {
    __qfp32 t=rhs;
    t.sign^=1;
    return (*this)+t;
  }

  __qfp32 operator*(const __qfp32 &rhs) const
  {
    uint64_t t=mant;
    t*=rhs.mant;

    uint32_t tExp=exp+rhs.exp;
    //0 => 10.48
    //1 => 18.40
    //2 => 26.32
    //3 => 34.24
    //...
    //6 => 58.0

    //desired format 29.24
    if(tExp >= 3)
    {
      uint64_t limit=0x1FFFFFFF000000ULL;
      if(t > (limit>>((tExp-3)*8)))
        t=limit;
      else
        t<<=(tExp-3)*8;
    }
    else
      t>>=(3-tExp)*8;

    if((sign^rhs.sign) == 1)
      t=-t;

    __qfp32 result;
    result.initFromUnnormalized(t);

    return result;
  }

  __qfp32 div(const __qfp32 &rhs) const
  {
    //vhdl
    uint64_t rem=0;
    uint32_t quo=0;
    int32_t dexp=0;

    dexp=3+rhs.exp-exp;

    uint64_t k=rhs.mant;
    rem=k;
    uint32_t shlRem=0;

    uint32_t maxShftAllowed=0;

    if((mant < (1<<21) && mant >= (1<<13)) || dexp == 4)
      maxShftAllowed=1;
    else if((mant < (1<<13) && mant >= (1<<5)) || dexp == 5)
      maxShftAllowed=2;
    else if(mant < (1<<5) || dexp == 6)
      maxShftAllowed=3;

    if(rem < (1<<25) && maxShftAllowed > 0)
    {
      if(rem >= (1<<17) || maxShftAllowed == 1)
      {
        rem<<=8;
        shlRem=1;
      }
      else if(rem >= (1<<9) || maxShftAllowed == 2)
      {
        rem<<=16;
        shlRem=2;
      }
      else if(rem >= (1<<1) || maxShftAllowed == 3)
      {
        rem<<=24;
        shlRem=3;
      }
    }

    dexp-=shlRem;

    uint32_t rem_top=rem>>25;
    uint64_t div=mant;
    uint32_t top_bits=0;

    bool divByZero=false;

    uint32_t shl=0;
    if(mant < (1<<21))
    {
      if(mant >= (1<<13))
      {
        shl=1;
        top_bits=((div>>13)&0xFF);
      }
      else if(mant >= (1<<5))
      {
        shl=2;
        top_bits=((div>>5)&0xFF);
      }
      else if((mant&0x1F) != 0)
      {
        shl=3;
        top_bits=((div<<3)&0xFF);
      }
      else
      {
        divByZero=true;
      }
    }
    else
    {
      top_bits=((div>>21)&0xFF);
    }

    if(rem_top >= (top_bits<<1))
    {
      shl+=1;
    }

    div<<=shl*8;
    dexp+=shl;

    if(divByZero)
      dexp=7;

    div&=0xFFFFFFFFFL;
    rem&=0x1FFFFFFFFL;

    for(int i=0;i<29;++i)
    {
      rem<<=1;
      quo<<=1;

      rem&=0x3FFFFFFFFFFL;

      int64_t sub=(rem>>5)-div;

      if(sub >= 0)
      {
        uint64_t t=sub;
        rem=(t<<5)+(rem&31);
        quo+=1;
      }
    }

    uint64_t res=quo;
    int32_t exp2=dexp;
    uint32_t sign2=rhs.sign^sign;

    //norm
    if(exp2 > 3)
    {
      exp2-=1;
      res<<=8;
    }

    int shiftCount=0;
    while(exp2 > 0 && ((res>>45)&0xFF) == 0)
    {
      res<<=8;
      --exp2;
      if(++shiftCount == 3)
        break;
    }

    if(exp2 > 3)
      res=0x1FFFFFFF000000,exp2=3;

    if(res == 0)
      exp2=0,sign2=0;

    if(exp2 < 0)
      assert(false);

    if(exp2 == 0 && (res>>24) == 0)
      sign2=0;

    return __qfp32(sign2,exp2,res>>24);
  }

  __qfp32 operator/(const __qfp32 &rhs)
  {
    return rhs.div(*this);
  }

  __qfp32 operator-() const
  {
    return __qfp32()-*this;
  }

  bool operator==(const __qfp32 &rhs) const
  {
    if(exp == rhs.exp && mant == 0 && rhs.mant == 0)
      ;//return true;

    return sign == rhs.sign && exp == rhs.exp && mant == rhs.mant;
  }

  bool operator>(const __qfp32 &rhs) const
  {
    __qfp32 result=rhs-(*this);
    return result.sign;
  }
  
  bool operator>=(const __qfp32 &rhs) const
  {
    return !(rhs > *this);
  }
  
  bool operator<=(const __qfp32 &rhs) const
  {
    return !(rhs < *this);
  }

  bool operator<(const __qfp32 &rhs) const { return rhs > *this; }

  __qfp32 abs() const { return __qfp32(0,exp,mant); }

  __qfp32 recp() const
  {
    if(mant == 0)
      return __qfp32(0,3,0x1FFFFFFF);

    //vhdl
    uint64_t rem=0;
    uint32_t quo=0;
    uint32_t dexp=0;

    if(exp == 3)
      rem=1;
    else if(exp == 2)
      rem=1<<8;
    else if(exp == 1)
      rem=1<<16;
    else
    {
      if(mant <= 8)
        rem=1,dexp=3;
      else if(mant <= 2048)
        rem=1<<8,dexp=2;
      else if(mant <= 256*2048)
        rem=1<<16,dexp=1;
      else
        rem=1<<24,dexp=0;
    }

    for(int i=0;i<30;++i)
    {
      rem<<=1;
      quo<<=1;

      int32_t sub=(rem>>5)-mant;

      if(sub >= 0)
      {
        uint64_t t=sub;
        rem=(t<<5)+(rem&31);
        quo+=1;
      }
    }

    uint32_t sign2=sign;
    if((quo>>1) == 0 && dexp == 0)
      sign2=0;

    return __qfp32(sign2,dexp,quo>>1);
  }
  
  __qfp32 log2() const
  {
    if((mant>>24) == 0 && exp == 0)
    {
      int32_t shift_bits=uint32_t(::floor(::log2(mant&0xFFFFFF)));
      if(mant == 0)
      {
        --shift_bits;//make compatible with hw
      }
	  
      //std::cout<<"xxx: "<<(24-shift_bits)<<std::dec<<"\n";
      uint32_t int_part=23-shift_bits;
      uint32_t m=(mant&0xFFFFFF)<<(24-shift_bits);
      //std::cout<<"shift bits: "<<(shift_bits)<<"  int_part: "<<(int_part)<<"\n";
      return __qfp32(1,0,(int_part<<24)|((~m)&0xFFFFFF));
    }
    else
    {
      uint32_t shift_bits=uint32_t(::floor(::log2(mant>>21)));
      //std::cout<<std::hex<<"ttt: "<<(mant>>21)<<std::dec<<"\n";
      uint32_t int_part=((shift_bits&0x7)|(exp*8))-3;
      uint32_t m=(mant>>5)<<(8-shift_bits);
      //std::cout<<"shift bits: "<<(shift_bits)<<"  int_part: "<<(int_part)<<"\n";
      return __qfp32(0,0,(int_part<<24)|(((m)&0xFFFFFF)));
    }
  }

   __qfp32 trunc() const
   {
     uint32_t m=mant&(~(0xFFFFFF>>(8*exp)));
     return __qfp32(sign && m != 0,exp,m);
   }

  __qfp32 logicAnd(const __qfp32 &rhs) const
  {
    uint64_t a=uint64_t(mant)<<(exp*8);
    uint64_t b=uint64_t(rhs.mant)<<(rhs.exp*8);
    
    __qfp32 result;
    result.initFromUnnormalized(a&b);
    return result;
  }

  __qfp32 logicOr(const __qfp32 &rhs) const
  {
    uint64_t a=uint64_t(mant)<<(exp*8);
    uint64_t b=uint64_t(rhs.mant)<<(rhs.exp*8);
    
    __qfp32 result;
    result.initFromUnnormalized(a|b);
    return result;
  }

  __qfp32 logicXor(const __qfp32 &rhs) const
  {
    uint64_t a=uint64_t(mant)<<(exp*8);
    uint64_t b=uint64_t(rhs.mant)<<(rhs.exp*8);
    
    __qfp32 result;
    result.initFromUnnormalized(a^b);
    return result;
  }

  __qfp32 logicShift(const __qfp32 &rhs) const
  {
    std::cout<<"logicShift:\n  a: "<<(*this)<<"\n  b: "<<(rhs)<<"\n";
    int32_t shf_value=rhs.mant>>(24-rhs.exp*8);
    if(shf_value > 63)
    {
      shf_value=63;
    }

    //std::cout<<"  mant: "<<std::hex<<(mant)<<std::dec<<"\n";
    //std::cout<<"  shf_value: "<<(shf_value)<<"\n";

    uint32_t lz1=23-((uint32_t)(::floor(::log2(mant&0xFFFFFF))));
    uint32_t lz2=7-((uint32_t)(::floor(::log2(mant>>21))));
    //std::cout<<"  lz1: "<<(lz1)<<"  log2: "<<(::floor(::log2(mant&0xFFFFFF)))<<"\n";
    //std::cout<<"  lz2: "<<(lz2)<<"\n";

    int32_t shf_exp=0;
    int32_t shf_dir=0;
    int32_t p1_exp=0;

    int32_t shf_val=0;

    if(rhs.sign == 0)
    {      
      if((mant>>24) == 0 && exp == 0)
      {
	      if(shf_value > (lz1+5))
				{
					shf_val=shf_value-(lz1+5);
				}
      }
      else if(shf_value > lz2)
      {
				shf_val=shf_value-lz2;
      }
    }
    else if(exp != 0 && shf_value >= (7-lz2))
    {
      shf_val=shf_value-(7-lz2); 
    }

    shf_exp=shf_val/8+((shf_val&7)?1:0);

    if(rhs.sign == 0)
    {
      shf_dir=0;
      p1_exp=exp+shf_exp;
      if(p1_exp > 7)
      {
				p1_exp=7;
      }
    }
    else
    {
      shf_dir=1;
      if(shf_exp > exp)
      {
				p1_exp=0;
				shf_exp=exp;
      }
      else
      {
				p1_exp=exp-shf_exp;
      }
    }

    int32_t shf_bits=shf_value-8*shf_exp;

    if(shf_bits < 0)
    {
      shf_dir^=1;
      shf_bits=-shf_bits;
    }

    uint32_t r=mant<<(shf_bits&0x1F);
    if(shf_dir == 1)
    {
      r=mant>>(shf_bits&0x1F);
    }

    if((shf_bits > 31 && shf_dir == 1) || mant == 0)
    {
      r=0;
      p1_exp=0;
    }

    if(p1_exp > 3)
    {
      r=0x1FFFFFFF;
      p1_exp=3;
    }

    uint32_t s=sign;
    if(r == 0)
    {
      s=0;
    }
    
    __qfp32 tt(s,p1_exp,r&0x1FFFFFFF);
    return tt;
  }
  
  operator double() const
  {
    double f=mant;
    f/=1<<(24-exp*8);


    if(sign)
      f=-f;

    return f;
  }

  operator float() const
  {
    return (float)(double)(*this);
  }

  operator int32_t() const
  {
    uint32_t tmp=mant;
    uint32_t round=0;

    if(exp < 3)
    {
      tmp=mant>>((3-exp)*8-1);
      round=tmp&1;
      tmp>>=1;
    }

    uint32_t result=tmp;

    if(sign)
      result=~result;

    uint32_t cy=0;
    if((sign^round) == 1)
      cy=1;

    result=result+cy;

    return result;
  }

  static __qfp32 random(uint32_t sign,uint32_t exp,uint32_t maxMantValuePlusOne=0x20000000)
  {
    assert(maxMantValuePlusOne <= 0x20000000);//assert max valid value

    uint32_t rand0=rand();
    rand0=(rand0<<13)^rand();

    uint32_t rand1=rand();
    rand1=(rand1<<13)^rand();

    uint32_t mant=0;

    if(maxMantValuePlusOne != 0)
      mant=rand0%maxMantValuePlusOne;

    if(exp > 0)
    {
      if(mant < (1<<21))
        mant|=(((rand1)%255)+1)<<21;
    }

    if(mant == 0)
      sign=0;

    return __qfp32(sign,exp,mant);
  }

  friend std::ostream& operator<<(std::ostream &out,const __qfp32 &qfp)
  {
    int64_t t=qfp.expand();

    if(t < 0)
      t=-t;

    uint32_t intPart=t>>24;
    uint64_t realPart=(t&0xFFFFFF);

    realPart*=100000000ULL;
    realPart/=1ULL<<24;
    
    char buf[22];
    //fraction
    int32_t i=0;
    uint32_t mask=1;
    for(i=0;i<8;++i)
    {
      uint32_t digit=(realPart/mask)%10;
      mask*=10;      
      buf[i]='0'+digit;
    }

    buf[i++]='.';

    //integer
    do
    {
      buf[i++]='0'+intPart%10;
      intPart/=10;

    }while(intPart > 0);

    if(qfp.expand() < 0)
      buf[i++]='-';

    while(i > 0)
      out<<(buf[--i]);

    return out;
  }

  bool isValidFormat()
  {
    if(mant == 0 && exp != 0)
      return false;

    if(exp == 1 && (mant>>16) < 32)
      return false;

    if(exp == 2 && (mant>>8) < 32*256)
      return false;

    if(exp == 2 && (mant) < 32*256*256)
      return false;

    return true;
  }

  uint32_t getSign() const { return sign; }
  uint32_t getExp() const { return exp; }
  uint32_t getMant() const { return mant; }
  
  uint32_t getAsRawUint() const { return asUint; }

protected:
  int64_t expand() const
  {
    int64_t t=(((int64_t)mant)<<(8*exp));
    return sign>0?-t:t;
  }

  uint32_t changeExp(uint32_t newExp)
  {
    assert(newExp >= 0 && newExp <= 3);

    uint32_t rd=0;

    if(newExp > exp)
    {
      mant>>=(newExp-exp)*8-1;
      rd=mant&1;
      mant>>=1;
    }
    else
      mant<<=(exp-newExp)*8;

    exp=newExp;
    return rd;
  }

  void initFromUnnormalized(int64_t raw)
  {
    //unnormalized format
    //29.24
    sign=raw<0?1:0;

    if(sign > 0)
      raw=-raw;

    if(raw >= 1LL<<53)
    {
      mant=0x1FFFFFFF;
      exp=3;
      return;
    }

    if(raw >= 1LL<<45)
    {
      mant=raw>>24;
      exp=3;
      return;
    }

    if(raw >= 1LL<<37)
    {
      mant=raw>>16;
      exp=2;
      return;
    }

    if(raw >= 1LL<<29)
    {
      mant=raw>>8;
      exp=1;
      return;
    }

    mant=raw;
    exp=0;

    if(mant == 0)
      sign=0;
  }
  
  union
  {
    struct
    {
      uint32_t mant :29;
      uint32_t exp  :2;
      uint32_t sign :1;
    };
    uint32_t asUint;
    int32_t asInt;
  };
};

inline __qfp32 operator-(const __qfp32 &a,int32_t i) { return a-__qfp32(i); }
inline __qfp32 operator-(const __qfp32 &a,float i) { return a-__qfp32(i); }
inline __qfp32 operator-(const __qfp32 &a,double i) { return a-__qfp32(i); }
inline __qfp32 operator+(const __qfp32 &a,int32_t i) { return a+__qfp32(i); }
inline __qfp32 operator+(const __qfp32 &a,float i) { return a+__qfp32(i); }
inline __qfp32 operator+(const __qfp32 &a,double i) { return a+__qfp32(i); }

typedef __qfp32 _qfp32_t;
typedef __qfp32 qfp32_t;
