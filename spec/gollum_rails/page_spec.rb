require 'spec_helper'

describe GollumRails::Page do
  before(:each) do
    @commit = {
      :name => "flo",
      :message => "commit",
      :email => "mosny@zyg.li"
    }
    @call = {
      :name => "Goole", 
      :content => "content data", 
      :commit => @commit, 
      :format => :markdown
    }
  end

  class RailsModel < GollumRails::Page

    register_validations_for :name,
                             :format

    validate do |validator|
      validator.test(:name, "type=String")
      validator.test(:format, "type=Object")
    end
  end
  it "should test the creation of a page" do
    rr = RailsModel.new(@call)
    rr.save.should be_instance_of Gollum::Page
    rr.save!.should be_instance_of Gollum::Page
    RailsModel.create(@call)
  end
  
  it "should test the update of a page" do
    rr = RailsModel.new @call
    cc = rr.save.should be_instance_of Gollum::Page
    rr.update_attributes({:name => "google", :format => :wiki}).should be_instance_of Gollum::Page
  end

  it "should test the deletion of a page" do
    rr = RailsModel.new @call
    cc = rr.save.should be_instance_of Gollum::Page
    rr.delete.should be_instance_of String
  end

  it "should test the finding of a page" do
    RailsModel.find('google').should be_instance_of Gollum::Page

    #invalid input
    RailsModel.find('<script type="text/javascript">alert(123);</script>').should be_nil
  end
  it "should test the preview" do
    rr = RailsModel.new :content => "# content", :name => "somepage"
    start = Time.new
    100.times do
      rr.preview.should == "<h1>content<a class=\"anchor\" id=\"content\" href=\"#content\"></a></h1>\n"
    end
    ending = Time.new
    puts "\n\t# 100 times preview took about: #{ending-start} seconds\n\t# 1 test took about #{(ending-start)/100} seconds\n\n"

  end

  it "should test the supported formats" do
    RailsModel.format_supported?('ascii').should be_true
    RailsModel.format_supported?('markdown').should be_true
    RailsModel.format_supported?('github-markdown').should be_true
    RailsModel.format_supported?('rdoc').should be_true
    RailsModel.format_supported?('org').should be_true
    RailsModel.format_supported?('pod').should be_true
  end

  it "should test getters" do
    rr = RailsModel.new @call
    rr.name.should == "Goole"
    rr.content.should == "content data"
    rr.commit.should be_instance_of Hash
    rr.commit.should == @commit
    rr.format.should == :markdown
    rr.wiki.should be_instance_of Gollum::Wiki
    RailsModel.validator.should == GollumRails::Adapters::ActiveModel::Validation
    rr.save
    rr.page.should be_instance_of GollumRails::Adapters::Gollum::Page
  end
  it "should test setters" do
    rr = RailsModel.new
    rr.name=("google").should == "google"
    rr.commit=(@commit).should == @commit
    rr.content=("content").should == "content"
    rr.format=(:markdown).should == :markdown
  end

end