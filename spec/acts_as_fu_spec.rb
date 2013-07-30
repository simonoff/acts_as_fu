require 'spec_helper'

describe ActsAsFu do
  include ActsAsFu::Base
  
  def create_models
    build_model(:foos) do
      string :name
      integer :age
      
      def self.awesome?; true end
    end
    
    build_model(:bars) do
      integer :foo_id
      
      belongs_to :foo
    end
  end
  
  describe "build_models" do
    it "returns the new klass" do
      klass = build_model(:people) do
        string :name
      end
      
      klass.should == Person
    end
  end
  
  describe "without building a model" do
    it "asplodes" do
      proc {
        Foo
      }.should raise_error
    end
  end
  
  describe "after building a model" do
    before(:each) do
      create_models
    end
    
    it "creates the class" do
      proc {
        Foo
      }.should_not raise_error
    end
    
    it "allows access to class" do
      Foo.should be_awesome
    end
    
    describe "the class" do
      it "is a subclass of ActiveRecord::Base" do
        Foo.superclass.should == ActsAsFu::Connection
      end
      
      it "has specified attributes" do
        foo = Foo.create! :name => "The WHIZ", :age => 100
        foo.name.should == "The WHIZ"
        foo.age.should == 100
      end
      
      it "is really real" do
        Foo.validates_presence_of :name
        proc {
          Foo.create! :age => 100
        }.should raise_error(ActiveRecord::RecordInvalid)
      end      
    end
    
    describe "rebuilding the class" do
      it "clears the table" do
        create_models
        5.times { Foo.create!(:name => "The WHIZ", :age => 100) }
        Foo.count.should == 5
        create_models
        Foo.count.should == 0
      end
      
      it "resets the class" do
        create_models
        class << Foo; attr_reader :bar end
        
        proc { Foo.bar }.should_not raise_error
        
        create_models
        proc { Foo.bar }.should raise_error(NoMethodError)
      end

      it "resets the attributes" do
        build_model :fakers do
          string :bar
        end
        proc { Faker.new :bar => "bar" }.should_not raise_error
        proc { Faker.new :foo => "foo" }.should     raise_error

        build_model :fakers do
          string :foo
        end
        proc { Faker.new :foo => "foo" }.should_not raise_error
        proc { Faker.new :bar => "bar" }.should     raise_error
      end
    end
    
    describe "single table inheritance" do
      it "allows superclass to be specified" do
        build_model(:assets) do
          string :type
          string :name
          
          if ActiveRecord::VERSION::MAJOR < 3
            named_scope :pictures, -> { where(type: 'Picture') }
          else
            scope :pictures, -> { where(type: 'Picture') }
          end
        end
        
        build_model(:pictures, :superclass => Asset)
        
        proc {
          Picture.create!
        }.should change(Asset.pictures, :count)
      end
    end

    describe "nested class" do
      it "is contained in a class" do
        class Foo::SubThing; end

        build_model(:sub_things, :contained => Foo) do
          string :name
        end

        proc {
          Foo::SubThing.create :name => "foo"
        }.should change(Foo::SubThing, :count)
      end
    end

  end
  
  describe "ActsAsFu.report!" do
    it "has a log" do
      create_models
      ActsAsFu::Connection.log.should include("CREATE TABLE")
    end
  end

  describe "custom DB config" do
    attr_reader :db
    
    before(:each) do
      system("rm -rf #{db}")
      @db = "#{File.dirname(__FILE__)}/tmp.sqlite3"
    end
    
    it "allows connection to custom DB config" do
      ActsAsFu::Connection.connect! \
        :adapter => 'sqlite3',
        :database => db
      
      build_model(:others) do
        string :body
      end
      
      File.exists?(db).should be_true
    end
    
    after(:each) do
      system("rm -rf #{db}")
    end
  end
end
