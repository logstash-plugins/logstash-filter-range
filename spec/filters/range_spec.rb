require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/range"

describe LogStash::Filters::Range do

  subject { described_class.new(config) }

  before(:each) do
    subject.register
    subject.filter(event)
  end

  describe "range match integer field on tag action" do
    let(:config) do
      { "ranges" => ["duration", 10, 100, "tag:cool",
                     "duration", 1, 1, "tag:boring"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50) }

    it "adds the in-range tag" do
      expect(event.get("tags")).to include("cool")
    end

    it "does not add the out-of-range tag" do
      expect(event.get("tags")).not_to include("boring")
    end
  end

  describe "range match float field on tag action" do
    let(:config) do
      { "ranges" => ["duration", 0, 100, "tag:cool",
                     "duration", 0, 1, "tag:boring"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50.0) }

    it "adds the in-range tag" do
      expect(event.get("tags")).to include("cool")
    end

    it "does not add the out-of-range tag" do
      expect(event.get("tags")).not_to include("boring")
    end
  end

  describe "range match string field on tag action" do
    let(:config) do
      { "ranges" => ["length", 0, 10, "tag:cool",
                     "length", 0, 1, "tag:boring"] }
    end
    let(:event) { LogStash::Event.new("length" => "123456789") }

    it "adds the in-range tag" do
      expect(event.get("tags")).to include("cool")
    end

    it "does not add the out-of-range tag" do
      expect(event.get("tags")).not_to include("boring")
    end
  end

  describe "range match with negation" do
    let(:config) do
      { "ranges" => ["length", 0, 10, "tag:cool",
                     "length", 0, 1, "tag:boring"],
        "negate" => true }
    end
    let(:event) { LogStash::Event.new("length" => "123456789") }

    it "does not add the in-range tag when negated" do
      expect(event.get("tags")).not_to include("cool")
    end

    it "adds the out-of-range tag when negated" do
      expect(event.get("tags")).to include("boring")
    end
  end

  describe "range match on drop action" do
    let(:config) do
      { "ranges" => ["length", 0, 10, "drop"] }
    end
    let(:event) { LogStash::Event.new("length" => "123456789") }

    it "cancels the event" do
      expect(event).to be_cancelled
    end
  end

  describe "range match on field action with string value" do
    let(:config) do
      { "ranges" => ["duration", 10, 100, "field:cool:foo",
                     "duration", 1, 1, "field:boring:foo"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50) }

    it "adds the in-range field" do
      expect(event.include?("cool")).to be true
      expect(event.get("cool")).to eq("foo")
    end

    it "does not add the out-of-range field" do
      expect(event.include?("boring")).to be false
    end
  end

  describe "range match on field action with integer value" do
    let(:config) do
      { "ranges" => ["duration", 10, 100, "field:cool:666",
                     "duration", 1, 1, "field:boring:666"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50) }

    it "adds the in-range field" do
      expect(event.include?("cool")).to be true
      expect(event.get("cool")).to eq(666)
    end

    it "does not add the out-of-range field" do
      expect(event.include?("boring")).to be false
    end
  end

  describe "range match on field action with float value" do
    let(:config) do
      { "ranges" => ["duration", 10, 100, "field:cool:3.14",
                     "duration", 1, 1, "field:boring:3.14"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50) }

    it "adds the in-range field" do
      expect(event.include?("cool")).to be true
      expect(event.get("cool")).to eq(3.14)
    end

    it "does not add the out-of-range field" do
      expect(event.include?("boring")).to be false
    end
  end

  describe "range match on tag action with dynamic string value" do
    let(:config) do
      { "ranges" => ["duration", 10, 100, "tag:cool_%{dynamic}_dynamic",
                     "duration", 1, 1, "tag:boring_%{dynamic}_dynamic"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50, "dynamic" => "and") }

    it "adds the in-range dynamic tag" do
      expect(event.get("tags")).to include("cool_and_dynamic")
    end

    it "does not add the out-of-range dynamic tag" do
      expect(event.get("tags")).not_to include("boring_and_dynamic")
    end
  end

  describe "range match on field action with dynamic string field and value" do
    let(:config) do
      { "ranges" => ["duration", 10, 100, "field:cool_%{dynamic}_dynamic:foo_%{dynamic}_bar",
                     "duration", 1, 1, "field:boring_%{dynamic}_dynamic:foo_%{dynamic}_bar"] }
    end
    let(:event) { LogStash::Event.new("duration" => 50, "dynamic" => "and") }

    it "adds the in-range dynamic field with dynamic value" do
      expect(event.include?("cool_and_dynamic")).to be true
      expect(event.get("cool_and_dynamic")).to eq("foo_and_bar")
    end

    it "does not add the out-of-range dynamic field" do
      expect(event.include?("boring_and_dynamic")).to be false
    end
  end
end
