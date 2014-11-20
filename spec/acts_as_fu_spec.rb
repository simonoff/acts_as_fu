require 'spec_helper'

describe ActsAsFu do
  include ActsAsFu
  
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
      
      expect(klass).to eq(Person)
    end
  end
  
  describe "without building a model" do
    it "asplodes" do
      expect {
        Foo
      }.to raise_error
    end
  end
  
  describe "after building a model" do
    before(:each) do
      create_models
    end
    
    it "creates the class" do
      expect {
        Foo
      }.not_to raise_error
    end
    
    it "allows access to class" do
      expect(Foo).to be_awesome
    end
    
    describe "the class" do
      it "is a subclass of ActiveRecord::Base" do
        expect(Foo.superclass).to eq(ActsAsFu::Connection)
      end
      
      it "has specified attributes" do
        foo = Foo.create! :name => "The WHIZ", :age => 100
        expect(foo.name).to eq("The WHIZ")
        expect(foo.age).to eq(100)
      end
      
      it "is really real" do
        Foo.validates_presence_of :name
        expect {
          Foo.create! :age => 100
        }.to raise_error(ActiveRecord::RecordInvalid)
      end      
    end
    
    describe "rebuilding the class" do
      it "clears the table" do
        create_models
        5.times { Foo.create!(:name => "The WHIZ", :age => 100) }
        expect(Foo.count).to eq(5)
        create_models
        expect(Foo.count).to eq(0)
      end
      
      it "resets the class" do
        create_models
        class << Foo; attr_reader :bar end
        
        expect { Foo.bar }.not_to raise_error
        
        create_models
        expect { Foo.bar }.to raise_error(NoMethodError)
      end

      it "resets the attributes" do
        build_model :fakers do
          string :bar
        end
        expect { Faker.new :bar => "bar" }.not_to raise_error
        expect { Faker.new :foo => "foo" }.to     raise_error

        build_model :fakers do
          string :foo
        end
        expect { Faker.new :foo => "foo" }.not_to raise_error
        expect { Faker.new :bar => "bar" }.to     raise_error
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
        
        expect {
          Picture.create!
        }.to change(Asset.pictures, :count)
      end
    end

    describe "nested class" do
      it "is contained in a class" do
        class Foo::SubThing; end

        build_model(:sub_things, :contained => Foo) do
          string :name
        end

        expect {
          Foo::SubThing.create :name => "foo"
        }.to change(Foo::SubThing, :count)
      end
    end

  end
  
  describe "ActsAsFu.report!" do
    it "has a log" do
      create_models
      expect(ActsAsFu::Connection.log).to include("CREATE TABLE")
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
      
      expect(File.exists?(db)).to be_truthy
    end
    
    after(:each) do
      system("rm -rf #{db}")
    end
  end
end
