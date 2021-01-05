#pragma once

#include <string>
#include <regex>
#include <map>
#include <list>
#include <exception>
#include <sstream>
#include <iostream>
#include <cstdlib>

struct mtest
{
  enum {enableColor=1,enableStdCout=2};
  
  class random
  {
  public:
    random(uint32_t seed=0xb87cb6c4) { state_=seed; }    
    uint32_t getUint32()
    {
      state_=((state_<<7)^(state_>>13))*6189107U;
      return state_;
    }
    
  protected:
    uint32_t state_;
  };
  
  class manager;

  class test
  {
  public:
    friend class manager;
    
    struct group_handler_t { void (*setup_)(); void (*teardown_)(); };

    test() {}
    virtual ~test() {}

    virtual void testRun() =0;
    virtual void testSetup() {}
    virtual void testTeardown() {}
    
    static void groupSetup() {}
    static void groupTeardown() {}

    const std::string& getName() { return name_; }

  protected:
    virtual group_handler_t getGroupHandler() { return {test::groupSetup,test::groupTeardown}; }
    
    void setName(const std::string &name) { name_=name; }
    std::string name_;
  };

  class condition
  {
  public:
    enum type {fatal,expect,unknown};

    condition(bool cond,const std::string &desc,type ty) { cond_=cond; desc_=desc; type_=ty; }

    template<typename _T>
    condition& operator<<(const _T &data) { userDesc_ << data; return *this; }

    std::string getErrorDesc() const { return desc_; }
    std::string getUserErrorDesc() const { return userDesc_.str(); }

    bool isFatal() const { return type_ == fatal; }
    bool isError() const { return type_ != unknown; }

    bool isConditionFulfilled() const { return cond_; }

  protected:
    std::string desc_;
    std::stringstream userDesc_;
    bool type_;
    bool cond_;
  };

  class endOfTestException : std::exception
  {
  public:
    endOfTestException() {}
  };

  class manager
  {
  public:
    friend class test;

    const char *VERT="\u2502";
    const char *HORI="\u2500";
    const char *CONT="\u251C";
    const char *CONA="\u2514";
    
    const uint64_t npos=std::string::npos;

    manager():cout_(buffer_.rdbuf())
    {
      currentTestFailed_=false;
    }

    void runAllTests(const std::string &filter,uint32_t options,std::ostream &cout)
    {
      cout_.rdbuf(cout.rdbuf());
      std::streambuf *stdCoutBuf=std::cout.rdbuf();

      if(!(options&mtest::enableStdCout))
      {
        std::cout.rdbuf(buffer_.rdbuf());
      }
      
      if(options&mtest::enableColor)
      {
        colorRed_="\x1B[38;5;9m";
        colorGreen_="\x1B[38;5;10m";
        colorDef_="\x1B[39m";
      }

      uint32_t passed=0;
      uint32_t skipped=0;
      uint32_t failed=0;

      std::regex reRunFilter=buildFilterRegex(filter);
      std::regex reSkip=std::regex(".*DISABLED");

      for(auto &i : tests_)
      {
        std::string group=i.first;
        
        //create test list
        std::list<std::pair<std::string,test*>> testList;
        for(auto j : i.second)
        {
          std::string completeName=(group=="#group"?"":(group + ".")) + j->getName();

          if(!std::regex_match(completeName,reRunFilter))
          {
            continue;
          }

          if(std::regex_match(completeName,reSkip))
          {
            ++skipped;
            continue;
          }
          
          testList.push_back(std::make_pair(completeName,j));
        }

        if(testList.size() == 0)
        {
          continue;
        }
        
        //call groupSetup
        if(handler_.find(group) != handler_.end())
        {
          handler_.find(group)->second.setup_();
        }
        
        if(group == "#group")
        {
          cout_<<"[-----] tests without a group"<<" ("<<(testList.size())<<" tests)"<<std::endl;
        }
        else
        {
          cout_<<"[-----] "<<(group)<<" ("<<(testList.size())<<" tests)"<<std::endl;
        }

        for(auto j : testList)
        {
          test *t=j.second;
          
          cout_<<"[ RUN ] "<<(j.first)<<std::endl;
          
          currentTestName_=j.first;
          currentTestFailed_=false;

          try
          {
            t->testSetup();
            t->testRun();
            t->testTeardown();
          }
          catch(const endOfTestException &e)
          {
            currentTestFailed_=true;
          }
          catch(...)
          {
            currentTestFailed_=true;
            cout_<<"   "<<(CONT)<<(HORI)<<" Unexpected Exception\n   "<<(VERT)<<std::endl;
            
            //teardown is case of error
            try
            {
              t->testTeardown();
            }
            catch(...) { cout_<<"   "<<(CONT)<<(HORI)<<" Teardown Exception\n   "<<(VERT)<<std::endl; }            
          }

          if(currentTestFailed_)
          {
            ++failed;
            cout_<<"   "<<(CONA)<<(HORI)<<colorRed_<<" FAILED"<<colorDef_<<std::endl;
            continue;
          }

          ++passed;
          cout_<<"   "<<(CONA)<<(HORI)<<colorGreen_<<" PASSED"<<colorDef_<<std::endl;
        }

        //call groupTeardown
        if(handler_.find(group) != handler_.end())
        {
          handler_.find(group)->second.teardown_();
        }
        
        cout_<<"[-----]\n"<<std::endl;
      }

      cout_<<((failed > 0)?colorRed_:colorGreen_)
           <<(failed)<<" FAILED  "
           <<(passed)<<" PASSED  "
           <<(skipped)<<" SKIPPED\n"
           <<(colorDef_)<<std::endl;

      //restore std::cout buffer
      std::cout.rdbuf(stdCoutBuf);
    }

    void addTest(const std::string &group,const std::string &name,test *t,test::group_handler_t handler={0,0})
    {
      t->setName(name);

      auto i=tests_.find(group);

      if(i == tests_.end())
      {
        i=tests_.insert(std::make_pair(group,std::list<test*>())).first;
      }

      i->second.push_back(t);
      
      if(handler.setup_ && handler.teardown_)
      {
        handler_.insert(std::make_pair(group,handler));
      }
    }

    void operator=(const condition &cond)
    {
      if(cond.isConditionFulfilled())
      {
        return;
      }

      if(currentTestFailed_ == false)
      {
        cout_<<"   "<<(VERT)<<"\n";
      }

      if(cond.isError())
      {
        currentTestFailed_=true;
        cout_<<"   "<<(CONT)<<(HORI)<<" "<<(cond.getErrorDesc())<<"\n";
      }

      if(!cond.getUserErrorDesc().empty())
      {
        std::string newLIneRep=std::string("\n   ")+VERT+"  ";

        cout_<<"   "<<(VERT)<<"  ";

        std::string desc=cond.getUserErrorDesc();

        uint64_t pos=desc.find_first_of("\n");
        while(pos != npos)
        {
          desc.replace(pos,1,newLIneRep);
          pos=desc.find_first_of("\n",pos+1);
        }

        cout_<<desc<<"\n";
      }

      cout_<<"   "<<(VERT)<<"\n";

      if(cond.isFatal())
      {
        throw endOfTestException();
      }
    }

    std::string getCurrentTestName() const { return currentTestName_; }

    static manager& instance() { static manager m; return m; }

  protected:
    std::regex buildFilterRegex(std::string filter)
    {
      std::string re;

      while(filter.length() > 0)
      {
        if(!re.empty())
        {
          re+="|";
        }

        uint64_t pos=filter.find_first_of(" |,");
        std::string sub=filter.substr(0,pos);
        re+='(' + prepareForRegex(sub) + ')';

        pos=std::min<uint32_t>(pos,filter.length()-1);
        filter=filter.substr(pos+1);
      }

      return std::regex(re);
    }

    std::string prepareForRegex(std::string s)
    {
      uint64_t pos=s.find_first_of(".*");

      while(pos != npos)
      {
        if(s[pos] == '.')
        {
          s.replace(pos,1,"\\.");
        }
        else
        {
          s.replace(pos,1,".*");
        }

        pos=s.find_first_of(".*",pos+2);//replace one with two chars
      }

      return s;
    }

    std::ostream cout_;
    std::stringstream buffer_;

    bool currentTestFailed_;

    std::string colorRed_;
    std::string colorGreen_;
    std::string colorDef_;

    std::string currentTestName_;

    std::map<std::string,std::list<test*>> tests_;
    std::map<std::string,test::group_handler_t> handler_;
  };
  
 static void runAllTests(uint32_t options=enableColor,std::ostream &cout=std::cout) { manager::instance().runAllTests("*",options,cout); }
 static void runAllTests(const std::string &filter,uint32_t options=enableColor,std::ostream &cout=std::cout) { manager::instance().runAllTests(filter,options,cout); }
};

#define MTEST_SINGLE(name) \
  class mtest##_group##name : public mtest::test \
  { \
  public: \
    mtest##_group##name() { mtest::manager::instance().addTest("#group",#name,this); } \
    virtual void testRun(); \
  }; \
  mtest##_group##name __mtest##group##name; \
  void mtest##_group##name::testRun()

#define MTEST_GROUP(group,name) \
  class mtest##group##name : public group \
  { \
  public: \
    mtest##group##name() { mtest::manager::instance().addTest(#group,#name,this,{group::groupSetup,group::groupTeardown}); } \
    virtual void testRun(); \
    std::string getGroup() const { return #group; } \
  }; \
  static mtest##group##name __mtest##group##name; \
  void mtest##group##name::testRun()

#define MTEST_SEL(_1,_2,SEL,...) SEL
#define MTEST(...) MTEST_SEL(__VA_ARGS__,MTEST_GROUP(__VA_ARGS__),MTEST_SINGLE(__VA_ARGS__))

#define REQUIRE(x) mtest::manager::instance()= \
    mtest::condition(x,std::string() + "Require \"" + #x + "\" failed (at line " + std::to_string(__LINE__) + ")",mtest::condition::fatal)

#define EXPECT(x) mtest::manager::instance()= \
    mtest::condition(x,std::string() + "Expect \"" + #x + "\" failed (at line " + std::to_string(__LINE__) + ")",mtest::condition::expect)
