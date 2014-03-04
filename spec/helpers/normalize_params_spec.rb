require 'spec_helper'
require 'json'
require File.dirname(__FILE__) + '/../../app/helpers/deckhand/normalize_params'

class Deckhand::DummyController
  include Deckhand::NormalizeParams
end

describe Deckhand::NormalizeParams do
  let(:params) { {} }
  let(:controller) { Deckhand::DummyController.new }

  before(:each) { controller.stub(params: params) }

  context "when non file params not present" do
    before(:each) { params[:not_related] = "Ignore" }

    it "does not change params" do
      controller.normalize_params
      expect(params).to eq({not_related: "Ignore"})
    end
  end

  context "when non file params present" do
    before(:each) do
      controller.stub(instance: double)
      params[:non_file_params] = "{\"model\":\"Model\",\"act\":\"Action\",\"form\":{\"code\":\"1234\",\"content\":{\"title\":\"Title\",\"file\":\"\"}}}"
    end

    it "removes original" do
      controller.normalize_params
      expect(params[:non_file_params]).to be_nil
    end

    it "converts from JSON" do
      controller.normalize_params
      expect(params["form"]).to eq({"code"=>"1234", "content"=>{"title"=>"Title", "file"=>""}})
    end

    it "wraps json data in form key" do
      controller.normalize_params
      expect(params["form"]).to eq({"code"=>"1234", "content"=>{"title"=>"Title", "file"=>""}})
    end

    it "appends model" do
      controller.normalize_params
      expect(params["model"]).to eq("Model")
    end

    it "appends action" do
      controller.normalize_params
      expect(params["act"]).to eq("Action")
    end

    it "takes care of files" do
      params[:form] = {"file" => "image.jpg"}
      controller.normalize_params
      expect(params["form"]["file"]).to eq("image.jpg")
    end

    it "takes care of files in group" do
      params[:form] = {"content.file" => "image.jpg"}
      controller.normalize_params
      puts params
      expect(params["form"]["content"]).to eq({"title"=>"Title", "file"=>"image.jpg"})
    end
  end
end