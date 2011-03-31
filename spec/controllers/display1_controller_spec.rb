require 'spec_helper'

describe Display1Controller do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'baseline_chart'" do
    it "should be successful" do
      get 'baseline_chart'
      response.should be_success
    end
  end

end
