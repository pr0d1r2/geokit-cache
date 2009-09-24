require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper')

describe <%= class_name %> do

  it "should provide geocode command" do
    <%= class_name %>.should respond_to(:geocode)
  end

end
