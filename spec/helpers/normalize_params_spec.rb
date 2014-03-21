require 'spec_helper'

describe Deckhand::NormalizeParams do
  let(:params) { {} }

  before do
    helper.stub(params: params)
    helper.stub(logger: double(debug: nil))
  end

  context "when non file params not present" do
    before { params[:not_related] = "Ignore" }

    it "does not change params" do
      helper.normalize_params
      expect(params).to eq({not_related: "Ignore"})
    end
  end

  context "when non file params present" do
    before do
      helper.stub(instance: double)
      params[:non_file_params] = "{\"model\":\"Model\",\"act\":\"Action\",\"form\":{\"code\":\"1234\",\"content\":{\"title\":\"Title\",\"file\":\"\"}}}"
    end

    it "removes original" do
      helper.normalize_params
      expect(params[:non_file_params]).to be_nil
    end

    it "converts from JSON" do
      helper.normalize_params
      expect(params["form"]).to eq({"code"=>"1234", "content"=>{"title"=>"Title", "file"=>""}})
    end

    it "wraps json data in form key" do
      helper.normalize_params
      expect(params["form"]).to eq({"code"=>"1234", "content"=>{"title"=>"Title", "file"=>""}})
    end

    it "appends model" do
      helper.normalize_params
      expect(params["model"]).to eq("Model")
    end

    it "appends action" do
      helper.normalize_params
      expect(params["act"]).to eq("Action")
    end

    it "takes care of files" do
      params[:form] = {"file" => "image.jpg"}
      helper.normalize_params
      expect(params["form"]["file"]).to eq("image.jpg")
    end

    it "takes care of files in group" do
      params[:form] = {"content.file" => "image.jpg"}
      helper.normalize_params
      expect(params["form"]["content"]).to eq({"title"=>"Title", "file"=>"image.jpg"})
    end
  end
end
